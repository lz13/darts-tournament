module TournamentsHelper
  def status_badge_class(status)
    base_classes = "inline-flex items-center rounded-full px-3 py-1 text-sm font-medium ring-1 ring-inset"

    case status
    when "draft"
      "#{base_classes} bg-gray-500/10 text-gray-400 ring-gray-500/20"
    when "in_progress"
      "#{base_classes} bg-emerald-500/10 text-emerald-400 ring-emerald-500/20"
    when "completed"
      "#{base_classes} bg-amber-500/10 text-amber-400 ring-amber-500/20"
    else
      "#{base_classes} bg-gray-500/10 text-gray-400 ring-gray-500/20"
    end
  end
end
