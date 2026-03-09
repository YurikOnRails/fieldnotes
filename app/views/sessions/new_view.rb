# frozen_string_literal: true

class Views::Sessions::NewView < Views::Base
  LABEL  = "block text-xs font-semibold uppercase tracking-[0.05em] text-[#57534E] mb-1.5"
  INPUT  = "w-full px-3 py-2 border border-[#D6D3D1] rounded-md text-sm text-[#1C1917] " \
            "bg-white focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/15 transition"

  def view_template
    if flash[:alert]
      div(class: "bg-[#FEF2F2] text-[#991B1B] border border-[#FECACA] rounded-lg px-4 py-3 mb-5 text-sm") do
        plain flash[:alert]
      end
    end

    h1(class: "text-xl font-bold text-[#1C1917] mb-6") { plain "Sign in" }

    form_with url: session_path do |f|
      div(class: "mb-4") do
        unsafe_raw f.label(:email_address, "Email", class: LABEL)
        unsafe_raw f.email_field(:email_address,
                                  required: true,
                                  autofocus: true,
                                  autocomplete: "username",
                                  placeholder: "you@example.com",
                                  value: view_context.params[:email_address],
                                  class: INPUT)
      end
      div(class: "mb-6") do
        unsafe_raw f.label(:password, "Password", class: LABEL)
        unsafe_raw f.password_field(:password,
                                     required: true,
                                     autocomplete: "current-password",
                                     placeholder: "••••••••",
                                     maxlength: 72,
                                     class: INPUT)
      end
      unsafe_raw f.submit("Sign in", class: "w-full px-4 py-2 bg-accent text-white rounded-md " \
                                            "text-sm font-medium cursor-pointer border-none " \
                                            "hover:bg-[#D4631E] transition")
    end

    div(class: "mt-4 text-center text-sm text-[#78716C]") do
      link_to "Forgot password?", new_password_path, class: "text-accent hover:text-[#D4631E]"
    end
  end
end
