# frozen_string_literal: true

class Views::Passwords::NewView < Views::Base
  LABEL = "block text-xs font-semibold uppercase tracking-[0.05em] text-[#57534E] mb-1.5"
  INPUT = "w-full px-3 py-2 border border-[#D6D3D1] rounded-md text-sm text-[#1C1917] " \
          "bg-white focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/15 transition"
  BTN   = "w-full px-4 py-2 bg-accent text-white rounded-md text-sm font-medium " \
          "cursor-pointer border-none hover:bg-[#D4631E] transition"

  def view_template
    h1(class: "text-xl font-bold text-[#1C1917] mb-6") { plain "Forgot your password?" }

    form_with url: passwords_path do |f|
      div(class: "mb-6") do
        unsafe_raw f.label(:email_address, "Email", class: LABEL)
        unsafe_raw f.email_field(:email_address,
                                  required: true,
                                  autofocus: true,
                                  autocomplete: "username",
                                  placeholder: "you@example.com",
                                  value: view_context.params[:email_address],
                                  class: INPUT)
      end
      unsafe_raw f.submit("Email reset instructions", class: BTN)
    end

    div(class: "mt-4 text-center text-sm text-[#78716C]") do
      link_to "Back to sign in", new_session_path, class: "text-accent hover:text-[#D4631E]"
    end
  end
end
