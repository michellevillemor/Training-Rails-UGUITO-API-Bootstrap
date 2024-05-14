class NorthUtility < Utility
    NOTE_SIZE_THRESHOLDS = {
        :short => 60,
        :medium => 120
    }

    def thresholds
        NOTE_SIZE_THRESHOLDS
    end
end
