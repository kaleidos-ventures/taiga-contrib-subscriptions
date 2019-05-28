###
# Copyright (C) 2014-2019 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: quaderno-billing.directive.coffee
###

QuadernoBillingDirective = ($compile) ->
    link = (scope, element, attrs) ->
        attrs.$observe 'label', (value) ->
            sc = document.createElement('script')

            sc.setAttribute('src','https://billing.quaderno.io/billing.js')
            sc.setAttribute('data-key', attrs.key)
            sc.setAttribute('data-customer-id', attrs.customerId)
            sc.setAttribute('data-editable', attrs.editable)
            sc.setAttribute('data-label', attrs.label)

            taiga.addClass(sc, 'quaderno-billing-button')

            element[0].appendChild(sc)

    return {
        link: link
    }

angular.module("subscriptions").directive("tgQuadernoBilling", QuadernoBillingDirective)
