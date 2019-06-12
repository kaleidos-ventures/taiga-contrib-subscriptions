###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: subscriptions.controller.coffee
###

module = angular.module('subscriptions')

class TaigaAppControler
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "tgLoader",
        "$translatePartialLoader",
        "$translate",
        "$tgAnalytics",
        "$tgConfig",
        "tgCurrentUserService",
        "tgUserService",
        "$tgAuth"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @tgLoader,
                @translatePartialLoader, @translate, @analytics, @config, @currentUserService, @userService,
                  @authService) ->
        @translatePartialLoader.addPart('taiga-contrib-subscriptions')

    init: ->
        @._loadMetas()
        @._loadMyPlan()
        @.appCode = null
        @.user = @currentUserService.getUser()

        Object.defineProperty @, "myPlan", {
            get: () => @.subscriptionsService.myPlan
        }


    _loadMetas: () ->
        sectionTitle = @translate.instant("TAIGA_APP.TITLE")
        description = @translate.instant("TAIGA_APP.SECTION_NAME")
        @.sectionName = @translate.instant("TAIGA_APP.SECTION_NAME")

        @appMetaService.setAll(sectionTitle, description)

    _loadMyPlan: ->
        @tgLoader.start()

        promise = @subscriptionsService.loadUserPlan()
        promise.then () =>
            @.appCode = @.myPlan.sync_code
            @tgLoader.pageLoaded()

module.controller("TaigaAppController", TaigaAppControler)
