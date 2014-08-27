module Applyance
  module Lib
    module Emails

      class Renderer < OpenStruct
        def self.from_hash(t, h)
          Applyance::Lib::Emails::Renderer.new(h).render(File.read(File.join(Applyance::Server.settings.root, "emails", "#{t}.erb")))
        end
        def render(template)
          ERB.new(template).result(binding)
        end
      end

      class Sender
        def self.send_template(template, source_message)
          m = Mandrill::API.new(Applyance::Server.settings.mandrill_api_key)

          content = Applyance::Lib::Emails::Renderer::from_hash(template[:template], template[:locals])
          template_name = "Applyance [API] [Team]"
          template_content = [{ "name" => "main", "content" => content }]

          message = {
            :from_name => "The Team at Applyance",
            :from_email => "contact@applyance.com"
          }.merge(source_message)

          puts "Sending email => [#{message[:subject]}, #{template[:template]}]."

          return if Applyance::Server.test?

          m.messages.send_template(template_name, template_content, message)
        end
      end

    end
  end
end
