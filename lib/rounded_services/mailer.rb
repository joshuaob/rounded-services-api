module Tipple
  class SendInBlue
    attr_accessor :env,
                  :my_email

    def initialize
      self.env = Tipple::Config.instance.env
      self.my_email = "hello@tipple.app"
    end

    def send_domain_validation_instructions(email:, domain_validation_dns_record:, domain:, template_id: 12)
      email_to = email
      email_attributes = {}
      email_attributes['env'] = env
      email_attributes['domain_validation_key'] = domain_validation_dns_record.name
      email_attributes['domain_validation_value'] = domain_validation_dns_record.value
      email_attributes['parking_id'] = domain.parking_id
      email_attributes['domain_name'] = domain.name

      if env == "production"
        send_template(template_id: 13, email_to: email_to, email_attributes: email_attributes)
      else
        send_template(template_id: template_id, email_to: email_to, email_attributes: email_attributes)
      end
    end

    def send_email_verification(email_verification:, template_id: 11)
      email_to = email_verification.email
      email_attributes = {}
      email_attributes['env'] = env
      email_attributes['passcode'] = email_verification.passcode

      send_template(template_id: template_id, email_to: email_to, email_attributes: email_attributes)
    end

    def send_signup(signup:, template_id: 7)
      email_to = signup.email
      email_attributes = {}
      email_attributes['env'] = env

      send_template(template_id: template_id, email_to: email_to, email_attributes: email_attributes)
    end

    def send_outreach_mail(outreach_mail:, template_id:)
      email_to = outreach_mail.email
      email_attributes = {}
      email_attributes['env'] = env
      return false unless outreach_mail.sent_at.nil?
      send_template(template_id: template_id, email_to: email_to, email_attributes: email_attributes)
    end

    def send_login_link(login_link:, template_id: 5)
      unless ["development", "staging", "production"].include?(env)
        raise "ENV #{env} has not been set up to send email"
      end

      unless [::ENV['ADMIN_EMAIL']].include?(login_link.email)
        raise "Error - #{login_link.email} has not been set up to send email"
      end

      email_to = login_link.email
      email_attributes = {}

      if env == "development"
        email_attributes["login_link"] = "http://localhost:4203/login?token=#{login_link.token}"
      end

      if env == "staging"
        email_attributes["login_link"] = "https://staging.web.recruiter.eireneapp.com/login?token=#{login_link.token}"
      end

      if env == "production"
        email_attributes["login_link"] = "https://recruiter.eireneapp.com/login?token=#{login_link.token}"
      end

      send_template(template_id: template_id, email_to: email_to, email_attributes: email_attributes)
    end

    def send_demo_invitation(template_id: 2, demo_invitation:)
      return unless ["development", "staging", "production"].include?(env)
      email_to = demo_invitation.email
      email_attributes = {}

      if env == "development"
        email_attributes['INVITATION_ACCEPT_LINK'] = "http://localhost:4202/invitations/accept?invitationId=#{demo_invitation.invitation_id}"
        email_attributes['INVITATION_ACCEPT_LINK_URL'] = "localhost:4202/invitations/accept?invitationId=#{demo_invitation.invitation_id}"
      end

      if env == "staging"
        email_attributes['INVITATION_ACCEPT_LINK'] = "https://staging.web.eireneapp.com/invitations/accept?invitationId=#{demo_invitation.invitation_id}"
        email_attributes['INVITATION_ACCEPT_LINK_URL'] = "staging.web.eireneapp.com/invitations/accept?invitationId=#{demo_invitation.invitation_id}"
      end

      if env == "production"
        email_attributes['INVITATION_ACCEPT_LINK'] = "https://eireneapp.com/invitations/accept?invitationId=#{demo_invitation.invitation_id}"
        email_attributes['INVITATION_ACCEPT_LINK_URL'] = "eireneapp.com/invitations/accept?invitationId=#{demo_invitation.invitation_id}"
      end

      send_template(template_id: template_id, email_to: email_to, email_attributes: email_attributes)
    end

    def forward_recruiter_enquiry(template_id: 4, recruiter_enquiry:)
      email_attributes = {}
      email_attributes["recruiter_name"] = recruiter_enquiry.name
      email_attributes["recruiter_organisation"] = recruiter_enquiry.organisation
      email_attributes["recruiter_email"] = recruiter_enquiry.email
      email_attributes["recruiter_enquiry"] = recruiter_enquiry.enquiry
      email_attributes["enquiry_env"] = env

      send_template(template_id: template_id, email_to: my_email, email_attributes: email_attributes)
    end

    def forward_enquiry(template_id: 6, enquiry:)
      email_attributes = {}
      email_attributes["enquiry_user_ref"] = enquiry.user_ref
      email_attributes["enquiry_user_kind"] = enquiry.user_kind
      email_attributes["enquiry_email"] = enquiry.email
      email_attributes["enquiry_message"] = enquiry.message
      email_attributes["enquiry_env"] = env

      send_template(template_id: template_id, email_to: my_email, email_attributes: email_attributes)
    end

    def forward_user_enquiry(template_id: 10, enquiry:)
      email_attributes = {}
      email_attributes["enquiry_user_ref"] = enquiry.user_ref
      email_attributes["enquiry_user_kind"] = enquiry.user_kind
      email_attributes["enquiry_email"] = enquiry.email
      email_attributes["enquiry_message"] = enquiry.message
      email_attributes["enquiry_env"] = env

      send_template(template_id: template_id, email_to: my_email, email_attributes: email_attributes)
    end

    # private

    def send_template(template_id:, email_to:, email_attributes:)
      api_instance = SibApiV3Sdk::SMTPApi.new

      send_email = SibApiV3Sdk::SendEmail.new
      send_email.email_to = [email_to]
      send_email.attributes = email_attributes

      begin
        api_instance.send_template(template_id, send_email)
      rescue SibApiV3Sdk::ApiError => e
        capture_exception("Exception when calling SMTPApi->send_template: #{e}")
        raise e
      end
    end
  end
end
