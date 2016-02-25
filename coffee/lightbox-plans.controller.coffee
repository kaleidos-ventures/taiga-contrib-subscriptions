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
# File: lightbox-plans.controller.coffee
###

module = angular.module('subscriptions')

class LightboxPlansController
    @.$inject = [
        "ContribSubscriptionsService",
        "tgLoader",
        "$tgConfirm",
        "lightboxService",
        "ContribStripeService"
    ]

    constructor: (@subscriptionsService, @tgLoader, @confirm, @lightboxService, @stripeService) ->
        Object.defineProperty @, "myPlan", {
            get: () => @.subscriptionsService.myPlan
        }
        Object.defineProperty @, "myRecommendedPlan", {
            get: () => @.subscriptionsService.myRecommendedPlan
        }

        Object.defineProperty @, "publicPlans", {
            get: () => @.subscriptionsService.publicPlans
        }

    selectPLan: (project) ->
        @.selectPlanInterval = 'month'

        if !project.is_applicable
            @.selectedPlan = 'invalid'
            @.invalidPlan = project
        else
            @.selectedPlan = 'valid'
            @.validPlan = project

    backToPLans: () ->
        @.selectedPlan = false

    _onSuccessBuyPlan: (plan) ->
        @lightboxService.closeAll()
        @tgLoader.start()

        @subscriptionsService.selectMyPlan(plan).then(@._onSuccessSelectPlan())

    buyPlan: () ->
        @.loadingStripe = true
        if @.myPlan.customer_id?
            planName = @.validPlan.name.toLowerCase()
            planInterval = @.selectPlanInterval
            plan = {
                'plan_id': planName + '-' + planInterval
            }
            @._onSuccessBuyPlan(plan)
        else
            @stripeService.start({
                name: 'Taiga',
                description: @.validPlan.name + ' Plan',
                amount: @.validPlan.amount,
                onLoad: () => @.loadingStripe = false
                onSuccess: @._onSuccessBuyPlan.bind(this)
                interval: @.selectPlanInterval
                plan: @.validPlan.name
            })

    _onSuccessSelectPlan: () ->

        @confirm.notify('success', 'OK, te has suscrito al plan correctamente', '', 5000)

        promise = @subscriptionsService.fetchMyPlans()
        promise.then () =>
            @tgLoader.pageLoaded()

module.controller("ContribLbPlansController", LightboxPlansController)
