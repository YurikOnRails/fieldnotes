# /pulse — "The World Right Now" (v2)

Real-time dashboard showing live data from public APIs.
Updates via Action Cable + Solid Cable — no new dependencies beyond v1 stack.

**Route:** `GET /pulse` — added to public navigation in v2.

---

## Data Sources (all free, no API key)

| Metric | Source | TTL |
|---|---|---|
| CO₂ ppm | NOAA API | 24h |
| Bitcoin price | `https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd` | 30s |
| People in space | `http://api.open-notify.org/astros.json` | on change |
| ISS position | `http://api.open-notify.org/iss-now.json` | 30s |
| Earthquakes today | `https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson` | 5min |
| US national debt | US Treasury Fiscal Data API | 24h |

Always show last cached value on API failure — never blank, never error.

---

## Architecture

```
Reader browser ←── Turbo Streams / Action Cable ──── Solid Cable (SQLite)
                                      ↑
                                PulseJob (every 30s)
                                fetches APIs → Solid Cache → broadcasts partials
```

---

## View

```erb
<%# app/views/public/pulse/index.html.erb %>
<%= turbo_stream_from "pulse" %>

<div id="co2_ppm">  <%= render "co2_ppm",  ppm:   @co2_ppm %>   </div>
<div id="btc_price"><%= render "btc_price", price: @btc_price %> </div>
<div id="iss">      <%= render "iss",       data:  @iss %>        </div>
<div id="quakes">   <%= render "quakes",    list:  @quakes %>     </div>
```

---

## PulseJob

```ruby
class PulseJob < ApplicationJob
  def perform
    Turbo::StreamsChannel.broadcast_replace_to "pulse",
      target: "btc_price",
      partial: "public/pulse/btc_price",
      locals: { price: CoinGeckoService.bitcoin_price }

    Turbo::StreamsChannel.broadcast_replace_to "pulse",
      target: "iss",
      partial: "public/pulse/iss",
      locals: { data: OpenNotifyService.iss_position }

    Turbo::StreamsChannel.broadcast_replace_to "pulse",
      target: "quakes",
      partial: "public/pulse/quakes",
      locals: { list: UsgsService.today_list }

    PulseJob.set(wait: 30.seconds).perform_later
  end
end
```

---

## Services

```
app/services/
  noaa_service.rb          # CO₂ ppm
  coin_gecko_service.rb    # Bitcoin price
  open_notify_service.rb   # ISS + astronauts
  usgs_service.rb          # Earthquakes
```

Each service: single `.fetch` class method, wraps `Rails.cache.fetch` with TTL,
returns last cached value on network error.

---

## Stimulus — client counters only

`pulse_controller.js` handles animated counters ticking locally (e.g. world population).
Server data → Turbo Streams. Local animation → Stimulus. Never mix.

```javascript
startCounter(baseValue, ratePerSecond) {
  setInterval(() => {
    baseValue += ratePerSecond / 10
    this.element.textContent = Math.floor(baseValue).toLocaleString()
  }, 100)
}
```

---

## Rules

- Never call external APIs inline in controller — always service + Solid Cache
- `PulseJob` self-reschedules; monitor via Solid Queue dashboard
- Page fully readable without WebSocket — initial render shows cached values
- Rate limit `/pulse` to 30 req/min
