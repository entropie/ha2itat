module Ha2itat
  module Helper
    module Pager

      MAX = 10

      def self.max
        (@max || Ha2itat.C(:pager_max) || MAX).to_i
      end

      def self.max=(i)
        @max = i
      end

      def self.paginate(params, list, n = nil)
        PagerNew.new(params, list, n || max)
      end

      class Pager
        attr_reader :params, :list, :link_proc
        attr_reader :pager

        class PagerArray

          def initialize(array, current_page, limit, pager)
            @array, @limit, @pager = array, limit, pager
            set_after_validation(current_page)
          end

          def set_after_validation(current_page_input)
            @page = if current_page_input.to_s.strip == "last"
                      page_count
                    elsif current_page_input =~ /^\d+$/
                      current_page_input.to_i
                    else
                      1
                    end
          end

          def page_count
            pages, rest = @array.size.divmod(@limit)
            rest == 0 ? pages : pages + 1
          end

          def current_page
            @page
          end

          def size
            @array.size
          end

          def to_a
            @array
          end

          def empty?
            @array.empty?
          end
        end


        class PagerItems < Array
        end


        def self.paginate(params, list, m = max)
          new(params, list, m)
        end

        def initialize(params, list, m = Helper::Pager.max)
          @limit = m
          @params, @list = params, list
          @pager = PagerArray.new(@list, @params[:page], m, self)
        end

        def limit
          @limit
        end

        def link_proc=(obj)
          @link_proc = obj
        end

        def current_page
          @pager.current_page
        end

        def pages
          items_for(current_page)
        end

        def size
          @pager.size
        end

        def empty?
          size == 0
        end

        def each(&blk)
          items_for(current_page).each(&blk)
        end

        def each_with_index(&blk)
          items_for(current_page).each_with_index(&blk)
        end

        def current_items
          items_for(current_page)
        end

        def items_for(pagenr)
          from = ((pagenr - 1) * @limit)
          to   = from + @limit
          @list[from...to] || []
        end

        def collect
          items = PagerItems.new

          #items << PagerNavigationItem.new(value: 1, text: "fbackward", pager: self)
          items << PagerNavigationItem.new(value: [current_page - 1, 1].max, text: "backward", pager: self)

          center = pager.current_page
          (1..pager.page_count).each_with_index do |pgnr|
            if [1, pager.page_count].include?(pgnr) or
              [center - 1, center, center + 1].include?(pgnr)

              items << PagerItem.new(value: pgnr, pager: self)
            else
              items << PagerSpacer.new(value: pgnr, pager: self)
            end
          end

          items << PagerNavigationItem.new(value: current_page + 1, text: "forward", pager: self)
          #items << PagerNavigationItem.new(value: pager.page_count, text: "fforward", pager: self)

          # iterate over entire list to find multiple succeeding spacer items and flatten them
          cleaned_items = PagerItems.new
          items.each_with_index do |itm, index|
            if itm.kind_of?(PagerSpacer)
              if items[index-1].kind_of?(PagerSpacer) or items[index+1].kind_of?(PagerSpacer)
                # make sure we only have one spacer item
                if not items[index-1].kind_of?(PagerSpacer)
                  cleaned_items << itm
                end
              else
                # when there is only a single spacer element, replace it with the actual page
                cleaned_items << itm.to_page_item
              end
            else
              cleaned_items << itm
            end
          end
          cleaned_items
        end

        def to_html(force = false)
          items = collect
          ret = ""
          items.each do |itm|
            ret << itm.to_html.to_s
          end

          return "" if pager.page_count < 2 and not force
          "<ul class='pager'>%s</ul>" % ret
        end

        alias :navigation :to_html


        class PagerItem

          attr_accessor :text, :value, :pager, :link_proc

          def initialize(text: nil, value:, pager:)
            @text = text
            @value = value
            @pager = pager
          end

          def css_cls
            act = active? ? " active" : ""
            "page-item%s%s" % [(disabled? ? " disabled" : ""), act]
          end

          def active?
            @pager.current_page == @value
          end

          def to_html
            li = "<li class='#{css_cls}'>%s</li>"
            ret = if disabled?
                    li % "<span data-href='%s'>%s</span>" % [(begin @pager.link_proc.call(value) end), @text || value]
                  else
                    li % "<a href='%s'>%s</a>" % [(begin @pager.link_proc.call(value) end), @text || value]
                  end

            ret
          end

          def disabled?
            return true if active?
            return true if @value > pager.pager.page_count
            return true if @value < 1
            return false
          end

          def inspect
            val = @value || ""
            act = (active? and not kind_of?(PagerNavigationItem)) ? "*" : " "
            "(%3s%s) (%s) [%s] -- %s" % [val, act, css_cls, text, pager.items_for(@value)]
          end
        end


        class PagerSpacer < PagerItem
          def css_cls
            "page-item page-spacer"
          end

          def inspect
            "..."
          end

          def to_html
            %Q(<li class="#{css_cls}"><a>...</a></li>)
          end

          def to_page_item
            PagerItem.new(value: value, text: text, pager: pager)
          end
        end


        class PagerNavigationItem < PagerItem

          include Helper::Translation

          def initialize(value:, text:, pager:)
            @value = value
            @text = text
            @pager = pager
          end

          def css_cls
            "page-item pager-navigation%s" % [(disabled? ? ' disabled' : '')]
          end

          def to_html
            li = "<li class='#{css_cls}'>%s</li>"
            icnstr = "<span class='pager-no-a'>#{t.icons.send(@text)}</span>"

            ret = if disabled?
                    li % icnstr
                  else
                    li % "<a href='%s'>%s</a>" % [(begin @pager.link_proc.call(value) end), icnstr]
                  end
            ret
          end


        end
      end

    end
  end
end
