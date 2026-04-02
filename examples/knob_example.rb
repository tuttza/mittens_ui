require '../lib/mittens_ui'

app_options = {
  name: "KnobExample",
  title: "Knob Example",
  height: 615,
  width: 570,
  can_resize: true
}.freeze


MittensUi::Application.Window(app_options) do
  # basic
  knob = MittensUi::Knob.new(min: 0, max: 100, value: 50, label: "Volume")
  knob.on_change { |v| puts "Volume: #{v}" }

  # synth style row of knobs
  MittensUi::HBox.new(spacing: 8) do
    MittensUi::Knob.new(min: 0, max: 127, value: 64, label: "Cutoff",    color: [0.2, 0.6, 1.0])
    MittensUi::Knob.new(min: 0, max: 127, value: 32, label: "Resonance", color: [1.0, 0.4, 0.2])
    MittensUi::Knob.new(min: 0, max: 127, value: 80, label: "Attack",    color: [0.8, 0.8, 0.2])
    MittensUi::Knob.new(min: 0, max: 127, value: 60, label: "Release",   color: [0.6, 0.2, 1.0])
  end

  # programmatic control
  knob.value = 75
  puts knob.value  # => 75.0

end
