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
# File: slack.coffee
###
debounce = (wait, func) ->
    return _.debounce(func, wait, {leading: true, trailing: false})


class SubscriptionsAdmin
    @.$inject = [
        "$rootScope",
        "$scope",
        "$tgRepo",
        "tgAppMetaService",
        "$tgConfirm",
        "$tgHttp",
    ]

    constructor: (@rootScope, @scope, @repo, @appMetaService, @confirm, @http) ->
        @scope.sectionName = "Subscriptions" # i18n
        @scope.sectionSlug = "subscriptions"

module = angular.module('taigaContrib.subscriptions', [])

module.controller("ContribSubscriptionsAdminController", SubscriptionsAdmin)

initSubscriptionsPlugin = ($tgUrls) ->
    $tgUrls.update({
        "subscriptions": "/subscriptions"
    })
module.run(["$tgUrls", initSubscriptionsPlugin])
