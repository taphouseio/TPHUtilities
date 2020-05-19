//
//  ObservableObject+DidChange.swift
//  Utilities
//
//  Created by Jared Sorge on 3/28/20.
//

import Combine

/*
 This file adds support for `ObjectDidChange` subscriptions on `ObservableObject` instances, which by default only can
 publish when the object _will_ change.

 Usage:
 observableObject.observe(\.foo, on: DispatchQueue.main) // get a keypath after willChange
 observableObject.observe(on: DispatchQueue.main) { object in
   // get the whole object after willChange
 }
 */

public extension ObservableObject {
    func observe<S: Scheduler>(on scheduler: S) -> ObjectDidChangePublisher<Self, S, Self> {
        observe(on: scheduler) { $0 }
    }

    func observe<S: Scheduler, Value>(_ keyPath: KeyPath<Self, Value>,
                                      on scheduler: S) -> ObjectDidChangePublisher<Self, S, Value> {
        observe(on: scheduler) { $0[keyPath: keyPath] }
    }

    func observe<S: Scheduler, Value>(on scheduler: S,
                                      transform: @escaping (Self) -> Value)
        -> ObjectDidChangePublisher<Self, S, Value> {
        ObjectDidChangePublisher(object: self, scheduler: scheduler, getOutput: transform)
    }
}

public struct ObjectDidChangePublisher<ObservedObject: ObservableObject, Context: Scheduler, Output>: Publisher {
    public typealias Failure = Never

    public var object: ObservedObject
    public var scheduler: Context
    private var getOutput: (ObservedObject) -> Output

    fileprivate init(object: ObservedObject, scheduler: Context, getOutput: @escaping (ObservedObject) -> Output) {
        self.getOutput = getOutput
        self.object = object
        self.scheduler = scheduler
    }

    public func observeOutput() -> Output {
        getOutput(object)
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
        let subscription = Subscription(publisher: self, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension ObjectDidChangePublisher {
    enum State {
        case unchanged
        case willChange
        case didChange
        case subscriberCancelled
    }

    class Subscription<S: Subscriber> where S.Failure == Failure, S.Input == Output {
        private var demand: Subscribers.Demand
        private var publisher: ObjectDidChangePublisher
        private var state: State
        private var subscriber: S
        private var subscriptions: Set<AnyCancellable>

        init(publisher: ObjectDidChangePublisher, subscriber: S) {
            demand = .none
            self.publisher = publisher
            state = .didChange
            self.subscriber = subscriber
            subscriptions = []

            publisher.object.objectWillChange.subscribe(self)
        }

        func objectDidFinishChanging() {
            switch state {
            case .subscriberCancelled, .didChange, .willChange:
                break
            case .unchanged:
                subscriber.receive(completion: .finished)
            }
        }

        func objectWillChange() {
            switch state {
            case .subscriberCancelled, .willChange:
                break
            case .unchanged, .didChange:
                state = .willChange
                publisher.scheduler.schedule {
                    self.state = .didChange
                    self.serviceDemand()
                }
            }
        }

        func serviceDemand() {
            guard demand > 0, case .didChange = state else { return }
            let output = publisher.observeOutput()
            state = .unchanged
            demand -= 1
            demand += subscriber.receive(output)
        }
    }
}

extension ObjectDidChangePublisher.Subscription: Subscriber {
    public typealias Input = ObservedObject.ObjectWillChangePublisher.Output
    public typealias Failure = Never

    public func receive(subscription: Subscription) {
        subscription.store(in: &subscriptions)
        subscription.request(.unlimited)
    }

    public func receive(_: Input) -> Subscribers.Demand {
        if case .subscriberCancelled = state {
            return .none
        } else {
            objectWillChange()
            return .max(1)
        }
    }

    public func receive(completion _: Subscribers.Completion<Never>) {
        subscriptions.removeAll()
        objectDidFinishChanging()
    }
}

extension ObjectDidChangePublisher.Subscription: Subscription {
    public func request(_ demand: Subscribers.Demand) {
        if case .subscriberCancelled = state {
            return
        }
        self.demand += demand
        serviceDemand()
    }

    public func cancel() {
        switch state {
        case .subscriberCancelled:
            break
        case .unchanged, .willChange, .didChange:
            state = .subscriberCancelled
            subscriptions.removeAll()
        }
    }
}
