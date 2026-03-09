# frozen_string_literal: true

module Views::Admin::Shared::AdminHelpers
  LABEL  = "block text-xs font-semibold uppercase tracking-[0.05em] text-[#57534E] mb-1.5"
  INPUT  = "w-full px-3 py-2 border border-[#D6D3D1] rounded-md text-sm text-[#1C1917] " \
            "bg-white focus:outline-none focus:border-accent focus:ring-2 focus:ring-accent/15 transition"
  HINT   = "mt-1 text-xs text-[#78716C]"
  CARD   = "bg-white rounded-xl shadow-sm p-6 mb-5"
  BTN_PRIMARY   = "inline-block px-4 py-2 bg-accent text-white rounded-md text-sm font-medium " \
                  "cursor-pointer border-none hover:bg-[#D4631E] transition no-underline"
  BTN_SECONDARY = "inline-block px-4 py-2 bg-[#E8E3DC] text-[#1C1917] rounded-md text-sm font-medium " \
                  "cursor-pointer border-none hover:bg-[#DDD8D0] transition no-underline"
  BTN_DANGER    = "inline-block px-3 py-1.5 bg-[#FEE2E2] text-[#991B1B] rounded-md text-xs font-medium " \
                  "cursor-pointer border-none hover:bg-[#FECACA] transition no-underline"

  def admin_card(title: nil, &block)
    div(class: CARD) do
      h2(class: "text-[1.0625rem] font-semibold mb-4 text-[#1C1917]") { plain title } if title
      yield
    end
  end

  def field_row(f, field_name, label_text: nil, hint: nil, type: :text_field, **opts)
    label_text ||= field_name.to_s.humanize
    div(class: "mb-4 last:mb-0") do
      unsafe_raw f.label(field_name, label_text, class: LABEL)
      unsafe_raw f.public_send(type, field_name, class: INPUT, **opts)
      p(class: HINT) { plain hint } if hint
    end
  end

  def error_list(record)
    return unless record.errors.any?
    div(class: "bg-[#FEF2F2] text-[#991B1B] border border-[#FECACA] rounded-lg px-4 py-3 mb-5 text-sm") do
      record.errors.each do |e|
        p { plain e.full_message }
      end
    end
  end

  def admin_toolbar(title:, &block)
    div(class: "flex items-center gap-4 mb-6") do
      h1(class: "text-[1.375rem] font-bold text-[#1C1917] m-0") { plain title }
      yield if block
    end
  end

  def admin_table_badge(status)
    render Components::Shared::Badge.new(status)
  end
end
