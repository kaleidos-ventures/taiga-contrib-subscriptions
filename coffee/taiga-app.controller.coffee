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
        "lightboxService",
        "$translatePartialLoader",
        "$translate",
        "ContribPaymentsService",
        "$tgAnalytics",
        "$tgConfirm",
        "$tgConfig",
        "tgCurrentUserService",
        "tgUserService",
        "$tgAuth"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @tgLoader, @lightboxService, @translatePartialLoader,
                  @translate, @paymentsService, @analytics, @confirm, @config, @currentUserService, @userService,
                  @authService) ->
        @translatePartialLoader.addPart('taiga-contrib-subscriptions')

    init: ->
        @._loadMetas()

        @.invalidPlan = null
        @.user = @currentUserService.getUser()
        console.log @.user
        @.userService.getContacts(@.user.get('id')).then (contacts) =>
            @.userContactsById = Immutable.fromJS({})
            contacts.forEach (contact) =>
                @.userContactsById = @.userContactsById.set(contact.get('id').toString(), contact)


    _loadMetas: () ->
        # sectionTitle = @translate.instant("SUBSCRIPTIONS.TITLE")
        # description = @translate.instant("SUBSCRIPTIONS.SECTION_NAME")
        # @.sectionName = @translate.instant("SUBSCRIPTIONS.SECTION_NAME")
        sectionTitle = "TAIGA APP"
        description = "desc"
        @.sectionName = "TAIGA APP"

        @appMetaService.setAll(sectionTitle, description)


module.controller("TaigaAppController", TaigaAppControler)
