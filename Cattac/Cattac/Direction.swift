/// Enumeration of all the possible directions that can be applied on a square
/// grid.
enum Direction: Int {
    case All = 0, Top, Right, Bottom, Left
    private var name: String {
        let names = [
            "all directions",
            "top direction",
            "right direction",
            "bottom direction",
            "left direction"
        ]

        return names[rawValue]
    }
}

extension Direction: Printable {
    var description: String {
        return name
    }

    /// Creates a Direction from a string value.
    ///
    /// :param: name The string representation of a Direction.
    /// :returns: A Direction of the given string input or nil if the string input is invalid.
    static func create(name: String) -> Direction? {
        let types = [
            "all directions": Direction.All,
            "top direction": Direction.Top,
            "right direction": Direction.Right,
            "bottom direction": Direction.Bottom,
            "left direction": Direction.Left
        ]

        return types[name]
    }
}