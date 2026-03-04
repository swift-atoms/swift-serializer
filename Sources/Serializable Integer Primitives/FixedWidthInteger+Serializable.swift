//
//  FixedWidthInteger+Serializable.swift
//  swift-serializer-primitives
//
//  Serializable conformances for standard library integer types.
//

extension Int: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<Int> { .init() }
}

extension UInt: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<UInt> { .init() }
}

extension Int8: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<Int8> { .init() }
}

extension Int16: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<Int16> { .init() }
}

extension Int32: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<Int32> { .init() }
}

extension Int64: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<Int64> { .init() }
}

extension UInt8: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<UInt8> { .init() }
}

extension UInt16: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<UInt16> { .init() }
}

extension UInt32: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<UInt32> { .init() }
}

extension UInt64: Serializable {
    public static var serializer: Serializer.ASCII.Integer.Decimal<UInt64> { .init() }
}
