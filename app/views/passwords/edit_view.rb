# frozen_string_literal: true

class Views::Passwords::EditView < Views::Base
  LABEL = "block text-xs font-semibold uppercase tracking-[0.05em] text-[#57534E] mb-1.5"
  INPUT = "w-full px-3 py-2 border border-[#D6D3D1] rounded-md text-sm text-[#1C1917] " \
          "bg-white focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/15 transition"
  BTN   = "w-full px-4 py-2 bg-accent text-white rounded-md text-sm font-medium " \
          "cursor-pointer border-none hover:bg-[#D4631E] transition"

  def initialize(token:)
    @token = token
  end

  def view_template
    h1(class: "text-xl font-bold text-[#1C1917] mb-6") { plain "Update your password" }

    form_with url: password_path(@token), method: :put do |f|
      div(class: "mb-4") do
        unsafe_raw f.label(:password, "New password", class: LABEL)
        unsafe_raw f.password_field(:password,
                                     required: true,
                                     autocomplete: "new-password",
                                     placeholder: "••••••••",
                                     maxlength: 72,
                                     class: INPUT)
      end
      div(class: "mb-6") do
        unsafe_raw f.label(:password_confirmation, "Confirm password", class: LABEL)
        unsafe_raw f.password_field(:password_confirmation,
                                     required: true,
                                     autocomplete: "new-password",
                                     placeholder: "••••••••",
                                     maxlength: 72,
                                     class: INPUT)
      end
      unsafe_raw f.submit("Save password", class: BTN)
    end
  end
end
