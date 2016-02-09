###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: subscriptions.coffee
###

#Controller
class SubscriptionsAdmin
    @.$inject = [
        "$scope",
        "tgAppMetaService",
        "tgSubscriptionsService"
    ]

    constructor: (@scope, @appMetaService, @subscriptionsService) ->
        @scope.pluginName = "Subscriptions - User Profile - Taiga" # i18n
        @scope.sectionName = "Upgrade Plan"

        console.log @subscriptionsService.getMyRecommendedPlan()
        @scope.myRecommendedPlan = @subscriptionsService.getMyRecommendedPlan()

        title = @scope.pluginName
        description = @scope.sectionName
        @appMetaService.setAll(title, description)

module = angular.module('taigaContrib.subscriptions', [])

module.controller("ContribSubscriptionsAdminController", SubscriptionsAdmin)

#Service
bindMethods = (object) =>
    dependencies = _.keys(object)

    methods = []

    _.forIn object, (value, key) =>
        if key not in dependencies
            methods.push(key)

    _.bindAll(object, methods)

class SubscriptionsService
    @.$inject = ["$tgHttp"]

    constructor: (@http) ->
        bindMethods(@)

    getMyRecommendedPlan: ->
        url = "http://localhost:5000/api-front/v1/my-recommended-plan"

        return @http.get(url, {}).then (response) ->
            console.log 'trolororo'
            return response.data

module.service("tgSubscriptionsService", SubscriptionsService)
