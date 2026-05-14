require 'rails_helper'
RSpec.describe TournamentsHelper, type: :helper do
  describe '#status_badge_class' do
    let(:base_classes) { "inline-flex items-center rounded-full px-3 py-1 text-sm font-medium ring-1 ring-inset" }
    it 'returns gray classes for draft status' do
      result = helper.status_badge_class('draft')
      expect(result).to include(base_classes)
      expect(result).to include('bg-gray-500/10')
      expect(result).to include('text-gray-400')
    end
    it 'returns emerald classes for in_progress status' do
      result = helper.status_badge_class('in_progress')
      expect(result).to include(base_classes)
      expect(result).to include('bg-emerald-500/10')
      expect(result).to include('text-emerald-400')
    end
    it 'returns amber classes for completed status' do
      result = helper.status_badge_class('completed')
      expect(result).to include(base_classes)
      expect(result).to include('bg-amber-500/10')
      expect(result).to include('text-amber-400')
    end
    it 'returns gray classes for unknown status' do
      result = helper.status_badge_class('unknown')
      expect(result).to include(base_classes)
      expect(result).to include('bg-gray-500/10')
      expect(result).to include('text-gray-400')
    end
  end
end
