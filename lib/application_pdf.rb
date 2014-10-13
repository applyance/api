module Applyance
  module Lib
    module ApplicationPdf

      def render_pdf

        application = self
        account = self.citizens.first.account
        fields = self.fields

        avatar_size = 1.25.in

        pdf = Prawn::Document.new do

          default_leading 5
          font "Helvetica", :style => :normal, :size => 12

          # Header

          bounding_box([0, cursor], :width => bounds.width) do

            lead = 0
            if account.avatar
              bounding_box([0, bounds.top], :width => avatar_size, :height => avatar_size) do
                image open(account.avatar.url),
                  :fit => [avatar_size, avatar_size],
                  :position => :center,
                  :vposition => :center
                transparent(0.25) { stroke_bounds }
              end
              lead = avatar_size + 0.25.in
            end

            bounding_box(
                [lead, bounds.top],
                :width => bounds.width - avatar_size - 0.25.in) do
              formatted_text [ { :text => account.name, :size => 20, :styles => [:bold] } ]
              text account.email
              text account.phone_number if account.phone_number
            end

            move_cursor_to bounds.bottom

          end

          move_down 0.25.in
          stroke_horizontal_rule
          move_down 0.5.in

          # Fields

          fields.each do |field|
            next if field.datum.attachments.length > 0

            formatted_text [ { :text => field.datum.definition.label, :styles => [:bold] } ]
            move_down 0.125.in

            if ['hourlyavailability', 'education', 'workexperience', 'address', 'legal', 'yesno', 'multiplechoice', 'reference', 'name'].include?(field.datum.definition.type)
              application.send("draw_field_#{field.datum.definition.type}", self, field)
            else
              if field.datum.detail['entries']
                field.datum.detail['entries'].each_with_index do |entry, index|
                  text " " if index > 0
                  entry.each do |k, prop|
                    text prop.to_s
                  end
                end
              else
                text field.datum.detail['value'].to_s
              end
            end

            move_down 0.5.in
          end

        end

        pdf.render

      end

      def draw_field_hourlyavailability(pdf, field)
        field.datum.detail['value'].each do |day, periods|
          pdf.text "#{day}: #{periods.join(", ")}"
        end
      end

      def draw_field_legal(pdf, field)
        pdf.text field.datum.detail['value'] == true ? "I accept" : "I don't accept"
      end

      def draw_field_yesno(pdf, field)
        pdf.text field.datum.detail['value'] == true ? "Yes" : "No"
      end

      def draw_field_multiplechoice(pdf, field)
        pdf.text field.datum.detail['value'].join(", ")
      end

      def draw_field_address(pdf, field)
        field.datum.detail['entries'].each_with_index do |entry, index|
          pdf.text " " if index > 0
          pdf.text entry['street1']
          pdf.text entry['street2'] if entry['street2']
          pdf.text "#{entry['city']}, #{entry['state']} #{entry['postal_code']} #{entry['country']}"
        end
      end

      def draw_field_reference(pdf, field)
        field.datum.detail['entries'].each_with_index do |entry, index|
          pdf.text " " if index > 0
          pdf.text entry['name']
          pdf.text "#{entry['relation']}, #{entry['phone_number']}"
        end
      end

      def draw_field_name(pdf, field)
        field.datum.detail['entries'].each_with_index do |entry, index|
          pdf.text " " if index > 0
          pdf.text "#{entry['first']} #{entry['last']}"
        end
      end

      def draw_field_education(pdf, field)
        field.datum.detail['entries'].each_with_index do |entry, index|
          pdf.text " " if index > 0
          pdf.text entry['institution']
          pdf.text entry['degree']
          pdf.text "#{entry['start_year']} - #{entry['end_year']}"
        end
      end

      def draw_field_workexperience(pdf, field)
        field.datum.detail['entries'].each_with_index do |entry, index|
          pdf.text " " if index > 0
          pdf.text entry['position_title']
          pdf.text "#{entry['company_name']}, #{entry['location']}"
          pdf.text "#{entry['start']} - #{entry['end']}"

          if entry['contact_supervisor']
            pdf.text " "
            pdf.text "You may contact my supervisor here: #{entry['supervisor_name']}, #{entry['supervisor_phone_number']}"
          end
        end
      end

    end
  end
end
