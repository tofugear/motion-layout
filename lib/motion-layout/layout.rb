module Motion
  class Layout
    def initialize(&block)
      @verticals   = [] # array of hash
      @horizontals = [] # array of hash
      @metrics     = {}

      yield self
      strain
    end

    def metrics(metrics)
      @metrics = Hash[metrics.keys.map(&:to_s).zip(metrics.values)]
    end

    def subviews(subviews)
      @subviews = Hash[subviews.keys.map(&:to_s).zip(subviews.values)]
    end

    def view(view)
      @view = view
    end

    def horizontal(horizontal, options=NSLayoutFormatAlignAllCenterY)
      @horizontals << {format: horizontal, options: options}
    end

    def vertical(vertical, options=NSLayoutFormatAlignAllCenterX)
      @verticals << {format: vertical, options: options}
    end

    private

    def strain
      @subviews.values.each do |subview|
        subview.translatesAutoresizingMaskIntoConstraints = false
        @view.addSubview(subview) unless subview.superview
      end

      views = @subviews.merge("superview" => @view)

      constraints = []
      constraints += @verticals.map do |vertical_hash|
        NSLayoutConstraint.constraintsWithVisualFormat("V:#{vertical_hash[:format]}", options:vertical_hash[:options], metrics:@metrics, views:views)
      end
      constraints += @horizontals.map do |horizontal_hash|
        NSLayoutConstraint.constraintsWithVisualFormat("H:#{horizontal_hash[:format]}", options:horizontal_hash[:options], metrics:@metrics, views:views)
      end

      @view.addConstraints(constraints.flatten)
    end
  end
end
