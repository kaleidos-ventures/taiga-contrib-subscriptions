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
# File: pricing.directive.coffee
###

module = angular.module('subscriptions')

PricingDirective = ($translate) ->
    link = (scope, el, attrs, ctrl) ->
        getAmount = () ->
            if (scope.plan.id == 'per-seat')
                return (scope.membersCount || 1 ) * scope.plan.amount_month
            else if (scope.plan.id == 'per-seat-free')
                return 0
            else if (scope.interval == 'month')
                return scope.plan.amount_month
            else if (scope.interval == 'year')
                return scope.plan.amount_year
            return null

        getFrequency = () ->
            if (scope.interval == 'month')
                return "/#{$translate.instant('SUBSCRIPTIONS.FREQUENCY_MONTH')}"
            else if (scope.interval == 'year')
                return "/#{$translate.instant('SUBSCRIPTIONS.FREQUENCY_YEAR')}"
            return null

        scope.$watchGroup(['plan', 'interval'], (values) ->
            if (values[0])
                scope.amount = getAmount()
                scope.frequency = getFrequency()
        )

    return {
        scope: {
            plan: '=', # object
            interval: '=', # string (month/year)
            membersCount: '=', # integer
            displayMonthlyTotalYear: '=' # boolean
            annotation: "=" # boolean
        },
        link: link,
        templateUrl: 'compile-modules/taiga-contrib-subscriptions/components/pricing/pricing.html',
    }

PricingDirective.$inject = [
    "$translate"
]


module.directive("tgPricing", PricingDirective)

