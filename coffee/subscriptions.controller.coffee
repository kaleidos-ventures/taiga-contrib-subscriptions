###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "tgLoader",
        "lightboxService",
        "$translatePartialLoader",
        "$translate",
        "ContribPaymentsService",
        "$tgConfirm"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @tgLoader, @lightboxService, @translatePartialLoader, @translate, @paymentsService, @confirm) ->
        @translatePartialLoader.addPart('taiga-contrib-subscriptions')

    init: ->
        @._loadMetas()
        @._loadPlans()

        Object.defineProperty @, "myPlan", {
            get: () => @.subscriptionsService.myPlan
        }

        Object.defineProperty @, "myRecommendedPlan", {
            get: () => @.subscriptionsService.myRecommendedPlan
        }

        Object.defineProperty @, "publicPlans", {
            get: () => @.subscriptionsService.publicPlans
        }

    _loadMetas: () ->
        sectionTitle = @translate.instant("SUBSCRIPTIONS.TITLE")
        description = @translate.instant("SUBSCRIPTIONS.SECTION_NAME")
        @.sectionName = @translate.instant("SUBSCRIPTIONS.SECTION_NAME")

        @appMetaService.setAll(sectionTitle, description)

    _loadPlans: ->
        @tgLoader.start()

        promise = @subscriptionsService.fetchMyPlans()
        promise.then () =>
            @tgLoader.pageLoaded()

    getTemplateUrl: () ->
        if !@.myRecommendedPlan
            plan = "paid"
        else if @.myRecommendedPlan.recommended_plan.amount_month == 0
            plan = "zero"
        else
            plan = "recommended"

        return "compile-modules/taiga-contrib-subscriptions/partials/subscriptions-"+plan+".html"

    upgradePlan: () ->
        @.loading = true

        promise = @subscriptionsService.fetchPublicPlans()
        promise.then(@._plansList.bind(this))

    buyRecommendedPlan: () ->
        @.loadingRecommendedPlan = true

        promise = @subscriptionsService.fetchPublicPlans()
        promise.then () =>
            @.loadingRecommendedPlan = false
            @lightboxService.open('tg-lb-plans')
            @.selectedPlan = 'valid'
            @.selectPlanInterval = 'month'
            @.validPlan = @.myRecommendedPlan.recommended_plan

    _plansList: (response) ->
        @.loading = false
        @.selectedPlan = false
        @lightboxService.open('tg-lb-plans')

    changePaymentsData: () ->
        description = @translate.instant("SUBSCRIPTIONS.PAYMENT_HISTORY.CHANGE_DATA")
        @paymentsService.changeData({
            name: 'Taiga',
            description: description
            onSuccess: @._onSuccessChangePaymentsData.bind(this)
        })

    _onSuccessChangePaymentsData: (data) ->
        @tgLoader.start()

        @subscriptionsService.selectMyPlan(data).then(@._onSuccessChangedData())

    _onSuccessChangedData: () ->
        message = @translate.instant("SUBSCRIPTIONS.PAYMENT_HISTORY.CHANGE_DATA_SUCCESS")

        @confirm.notify('success', message, '', 5000)

        promise = @subscriptionsService.fetchMyPlans()
        promise.then () =>
            @tgLoader.pageLoaded()

module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
