package acnl.unicode
public enum NormalizationForm <: Hashable & Equatable<NormalizationForm> {
    | NFC     // Form C     Canonical Decomposition, followed by Canonical Composition
    | NFD     // Form D     Canonical Decomposition
    | NFKC    // Form KC    Compatibility Decomposition, followed by Canonical Composition
    | NFKD    // Form KD    Compatibility Decomposition

    public func hashCode(): Int64 {
        match(this) {
            case NFC  => 1
            case NFD  => 2
            case NFKC => 5
            case NFKD => 6
        }
    }

    public operator func ==(that: NormalizationForm): Bool {
        this.hashCode() == that.hashCode()
    }
}