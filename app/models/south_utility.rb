class SouthUtility < Utility
    NOTE_SIZE_THRESHOLDS = {
        :short => 50,
        :medium => 100
    }

    def thresholds
        NOTE_SIZE_THRESHOLDS
    end
end
