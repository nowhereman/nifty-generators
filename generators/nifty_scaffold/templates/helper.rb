# The code in this file implements helper class <%= plural_class_name %>Helper.

# Class <%= plural_class_name %>Helper provides helpers available in all views of
# the <%= plural_class_name %>Controller.

module <%= plural_class_name %>Helper

<%- if options[:will_paginate] -%>

# Returns an interface for pagination using the will_paginate library.
#
# Parameters:
#
# [collection] Collection to paginate with
# [options] Options to customize pager with

def <%= singular_name %>_pagination(collection, options = {})
    if collection.total_entries > 1
      pager = will_paginate(collection, { :inner_window => 10,
                :next_label => t('common.actions.next_page'),
                :previous_label => t('common.actions.previous_page') }.merge(options))

      if not pager.blank?  
        return pager.respond_to?(:html_safe!) ? pager.html_safe! : pager
      end
    end

    return ''
  end
<%- end -%>
end