#-- copyright
#  OpenProject is an open source project management software.
#  Copyright (C) 2010-2022 the OpenProject GmbH
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License version 3.
#
#  OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
#  Copyright (C) 2006-2013 Jean-Philippe Lang
#  Copyright (C) 2010-2013 the ChiliProject Team
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#  See COPYRIGHT and LICENSE files for more details.

require 'spec_helper'

RSpec.describe Company do
  subject(:company) { create(:company, owner:) }

  let(:owner) { create(:user, firstname: 'the owner') }

  describe '#active_shares' do
    subject { company.active_shares }

    let!(:active_share) { create(:share, parent:, child: company, active: true) }
    let!(:inactive_share) { create(:share, parent:, child: company, active: false) }

    let(:parent) { create(:company) }

    it { is_expected.to include active_share }
    it { is_expected.not_to include inactive_share }
  end

  describe '#owning_users' do
    subject { company.owning_users.pluck(:firstname) }

    context 'when there is no active parent' do
      it { is_expected.to eq [owner.firstname] }
    end

    context 'when there are active parents' do
      let(:parent) { create(:company, owner: create(:user, firstname: 'parent owner')) }

      let(:owned_parent) { create(:company, owner: create(:user, firstname: 'owned parent owner')) }
      let(:grandparent) { create(:company, owner: create(:user, firstname: 'grandparent owner')) }

      let(:inactive_parent) { create(:company, owner: create(:user, firstname: 'inactive parent owner')) }

      before do
        create(:share, parent:, child: company, active: true)

        create(:share, parent: grandparent, child: owned_parent, active: true)
        create(:share, parent: owned_parent, child: company, active: true)

        create(:share, parent: inactive_parent, child: company, active: false)
      end

      it { is_expected.to include parent.owner.firstname }
      it { is_expected.to include grandparent.owner.firstname }

      it { is_expected.not_to include owner.firstname }
      it { is_expected.not_to include owned_parent.owner.firstname }
      it { is_expected.not_to include inactive_parent.owner.firstname }
    end
  end
end
