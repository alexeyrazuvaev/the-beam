class PagesController < ApplicationController
  def home
    @interviews = Interview.all
  end

  def ambassador
  end

  def buy
    @testimonials = Testimonial.all
  end

  def impressum
  end

  def solar_panel_art
  end
end
