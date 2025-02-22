module Gaku
  module GakuHelper
    # include SortHelper
    # include TranslationsHelper
    # include FlashHelper

    def broadcast(channel, &block)
      message = { channel: channel, data: capture(&block) }
      uri = URI.parse('http://localhost:9292/faye')
      Net::HTTP.post_form(uri, message: message.to_json)
    end

    def tr_for(resource)
      content_tag :tr, id: "#{resource.class.to_s.demodulize.underscore.dasherize}-#{resource.id}" do
        yield
      end
    end

    def current_parent_controller
      controller.controller_path.split('/').second
    end

    def current_controller_action
      controller.action_name
    end

    def drag_field
      content_tag :td, class: 'sort-handler' do
        content_tag :i, nil, class: 'icon-move'
      end
    end

    def can_edit?
      if controller.action_name.include?('edit')
        true
      else
        false
      end
    end

    def cannot_edit?
      !can_edit?
    end

    def genders
      { t(:'gender.female') => false, t(:'gender.male') => true }
    end

    def style_semester(date)
      date.strftime('')
    end

    def required_field
      content_tag :span, t(:required), class: 'label label-important pull-right'
    end

    def render_js_partial(partial, locals = {})
      if locals == {}
        escape_javascript(render(partial: partial, formats: [:html], handlers: %i[erb slim]))
      else
        escape_javascript(render(partial: partial, formats: [:html], handlers: %i[erb slim], locals: locals))
      end
    end

    def title(text)
      content_for(:title) do
        text
      end
    end

    def color_code(color)
      content_tag :div, nil, style: "width:100px;height:20px;background-color:#{color}"
    end

    def comma_separated_list(objects)
      if objects.any?
        objects.map do |object|
          block_given? ? yield(object) : object
        end.join(', ').html_safe
      else
        t(:empty)
      end
    end

    def prepare_target(nested_resource, address)
      return nil if nested_resource.blank?

      [nested_resource, address].flatten
    end

    def prepare_resource_name(nested_resources, resource)
      @resource_name = [nested_resources.map { |r| r.is_a?(Symbol) ? r.to_s : get_class(r) }, resource.to_s].flatten.join '-'
    end

    def exam_completion_info(exam)
      @course_students ||= @course.students
      ungraded = exam.ungraded(@course_students)
      total = exam.total_records(@course_students)

      percentage = number_to_percentage exam.completion(@course_students), precision: 2

      "#{t(:'exam.completion')}:#{percentage} #{t(:'exam.graded')}:#{total - ungraded} #{t(:'exam.ungraded')}:#{ungraded} #{t(:'exam.total')}:#{total}"
    end

    def datepicker_date_format(date)
      date ? date.strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d')
    end

    def extract_grouped(grouped, resource)
      grouped.map(&resource.to_sym)
    end

    def nested_header(text)
      content_tag :h4, text
    end

    def state_load(object)
      object.country.nil? ? Gaku::State.none : object.country.states
    end

    def disabled?(object)
      object.new_record? || object.country.states.blank?
    end

    def link_to_download(resource, options = {})
      name = content_tag(:span, nil, class: 'glyphicon glyphicon-download')
      attributes = {
        class: 'btn btn-xs btn-success download-link'
      }.merge(options)
      link_to name, resource, attributes
    end

    def ajax_link_to_recovery(resource, options = {})
      name = content_tag(:span, nil, class: 'glyphicon glyphicon-repeat')
      attributes = {
        remote: true,
        class: 'btn btn-xs btn-success recovery-link'
      }.merge(options)
      link_to name, resource, attributes
    end

    def icon(name)
      content_tag(:span, nil, class: name.to_s)
    end

    def icon_label(icon_name, label)
      raw %( #{icon(icon_name)} #{label} )
    end
  end
end
