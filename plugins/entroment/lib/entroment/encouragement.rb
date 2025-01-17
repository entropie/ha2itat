module Plugins
  module Entroment
    module Encouragements

      def encouragements
        [
          "Nice!",
          "Good job!",
          "Keep it up!",
          "Solid effort!",
          "Not bad at all!",
          "Well played!",
          "Clean!",
          "You're getting there!",
          "That's the way!",
          "Smooth move!",
          "Big brain!",
          "You're on fire!",
          "Poggers!",
          "Mega streak!",
          "Insane!",
          "Absolute legend!",
          "God tier!",
          "Unstoppable!",
          "Omega Pog!",
          "Giga Chad vibes!"
        ]
      end

      def serial_encouragement(n)
        encouragements[[n, encouragements.size].min - 1]
      end

      def html_encouragement(n)
        n += 1 if n < 1
        "<span class='streaktext sn-#{ [n, 20].min }'>#{serial_encouragement(n)}</span>"
      end
    end
  end
end
