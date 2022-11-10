// Copyright 2022-present 650 Industries. All rights reserved.

/**
 A dynamic type representing the `SharedObject` type and its subclasses.
 */
internal struct DynamicSharedObjectType: AnyDynamicType {
  let innerType: SharedObject.Type

  func wraps<InnerType>(_ type: InnerType.Type) -> Bool {
    return innerType == InnerType.self
  }

  func equals(_ type: AnyDynamicType) -> Bool {
    if let sharedObjectType = type as? Self {
      return sharedObjectType.innerType == innerType
    }
    return false
  }

  func cast<ValueType>(_ value: ValueType) throws -> Any {
    if let jsObject = try (value as? JavaScriptValue)?.asObject(),
       let nativeSharedObject = SharedObjectRegistry.toNativeObject(jsObject) {
      return nativeSharedObject
    }
    throw NativeSharedObjectNotFoundException()
  }

  var description: String {
    return "SharedObject<\(innerType)>"
  }
}

internal final class NativeSharedObjectNotFoundException: Exception {
  override var reason: String {
    "Unable to find the native shared object associated with given JavaScript object"
  }
}
