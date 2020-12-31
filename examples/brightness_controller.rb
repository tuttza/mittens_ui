#! /usr/bin/ruby

require 'mittens_ui'

app_options = {
  name: "brightness_controller",
  title: "Brightness Controller",
  height: 350,
  width: 350,
  can_resize: true
}.freeze

class Brightness
  attr_accessor :max_value, :current_value

  def initialize
    # Only works for on-board Intel based graphics.
    @current_path = "/sys/class/backlight/intel_backlight/brightness"
    @current_value = get_current
    @max_path = "/sys/class/backlight/intel_backlight/max_brightness"
    @max_value = get_max
  end

  def set(value)
    File.write(@current_path, value)
  end

  def is_root?
    case Process.uid
    when 0 then true
    else false
    end
  end

  private

  def get_max
    File.open(@max_path, "r") { |f| f.read }.strip
  end

  def get_current
    File.open(@current_path, "r") { |f| f.read }.strip
  end
end

MittensUi::Application.Window(app_options) do
  brightness = Brightness.new
  
  unless brightness.is_root?
    MittensUi::Alert(window, "To change your screen brightness level you must run this App as root.")
    window
  end

  MittensUi::Label("Current Brightness Level:", top: 25)

  slider_opts = { 
    start_value: 1, 
    stop_value: brightness.max_value, 
    initial_value: brightness.current_value
  }.freeze

  brightness_slider = MittensUi::Slider(layout, slider_opts)
  brightness.set(brightness_slider.value.to_i.to_s)
end