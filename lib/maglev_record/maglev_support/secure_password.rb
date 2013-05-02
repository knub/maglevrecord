module MaglevSupport
  module SecurePassword
    module ClassMethods
      def has_secure_password
        attr_reader :password

        validates_confirmation_of :password
        validates_presence_of     :password_digest

        mark_sensible :password, :password_confirmation
    
        include InstanceMethodsOnActivation

      end

      def encrypt_password(raw_password)
        Digest::SHA256.new.update(raw_password).to_s
      end
    end
    


    module InstanceMethodsOnActivation
      def authenticate(raw_password)
        if password_digest == self.class.encrypt_password(raw_password)
          self
        else
          false
        end
      end

      def password=(raw_password)
        require 'digest'
        attributes[:password] = raw_password
        unless raw_password.blank?
          self.password_digest = self.class.encrypt_password(raw_password)
        end
      end

      # def read_attribute_for_validation
    end

  end
end
