#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module Companies
      class CompanyRepresenter < ::API::Decorators::Single
        link :self do
          {
            href: api_v3_paths.company(represented.id),
            title: represented.name
          }
        end

        links :owningUsers do
          represented.owning_users.map do |owner|
            {
              href: api_v3_paths.user(owner.id),
              title: owner.name
            }
          end
        end

        property :id, render_nil: true
        property :name, render_nil: true

        def _type
          'Company'
        end

        collection :owningUsers,
                   embedded: true,
                   exec_context: :decorator,
                   getter: ->(*) {
                     represented.owning_users.map do |owner|
                       Users::UserRepresenter.create(owner, current_user:)
                     end
                   }
      end
    end
  end
end
