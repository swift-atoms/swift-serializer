// MARK: - Serializing.Value

extension Serialization.Serializing.Value where Context == Void {
    /// Convenience for context-free serialization.
    @inlinable
    public func call(_ value: Output) throws(Failure) -> Representation {
        try self.call(value, ())
    }
}

// MARK: - Serializing.Buffer

extension Serialization.Serializing.Buffer where Context == Void {
    /// Convenience for context-free buffer serialization.
    @inlinable
    public func call(_ value: Output, into buffer: inout [Element]) {
        self.call(value, (), &buffer)
    }

    /// Serializes to a new array (allocating variant).
    @inlinable
    public func returning(_ value: Output) -> [Element] {
        var buffer: [Element] = []
        self.call(value, (), &buffer)
        return buffer
    }
}

// MARK: - Parsing.Whole

extension Serialization.Parsing.Whole where Context == Void {
    /// Convenience for context-free whole parsing.
    @inlinable
    public func call(_ representation: Representation) throws(Failure) -> Output {
        try self.call(representation, ())
    }
}

// MARK: - Parsing.Prefix.Witness

extension Serialization.Parsing.Prefix.Witness where Context == Void {
    /// Convenience for context-free prefix parsing.
    @inlinable
    public func call(_ representation: Representation) throws(Failure) -> Serialization.Parsing.Prefix.Result<Output, Count> {
        try self.call(representation, ())
    }
}

// MARK: - Measuring

extension Serialization.Measuring where Context == Void {
    /// Convenience for context-free measuring.
    @inlinable
    public func call(_ value: Output) -> Int {
        self.call(value, ())
    }
}
