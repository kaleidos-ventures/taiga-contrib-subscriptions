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
# File: lightbox-plans.controller.coffee
###

module = angular.module('subscriptions')

class LightboxPlansController
    @.$inject = [
        "ContribSubscriptionsService",
        "tgLoader",
        "$tgConfirm",
        "lightboxService",
        "ContribPaymentsService",
        "tgCurrentUserService",
        "$tgAnalytics",
        "$translate",
        "$tgConfig"
    ]

    constructor: (@subscriptionsService, @tgLoader, @confirm, @lightboxService, @paymentsService,
                  @currentUserService, @analytics, @translate, @config) ->
        Object.defineProperty @, "myPlan", {
            get: () => @.subscriptionsService.myPlan
        }

        Object.defineProperty @, "myRecommendedPlan", {
            get: () => @.subscriptionsService.myRecommendedPlan
        }

        Object.defineProperty @, "publicPlans", {
            get: () => @.subscriptionsService.publicPlans
        }

    selectPlan: (project) ->
        @.invalidInterval = null
        @.selectPlanInterval = "month"
        if !project.is_applicable
            @.selectedPlan = 'invalid'
            @.invalidPlan = project
        else
            @.selectedPlan = 'valid'
            @.validPlan = project
            @analytics.addEcClickProduct(@.validPlan)
            @analytics.addEcImpression(@.validPlan, "Plan detail", 1)
            @analytics.addEcStep("select-plan", @.myPlan?.current_plan?.plan_id, @.validPlan)
            if @.myPlan && @.validPlan.name == @.myPlan.current_plan.name
                if @.myPlan.interval == "month"
                    @.invalidInterval = "month"
                    @.selectPlanInterval = "year"
                else if @.myPlan.interval == "year"
                    @.invalidInterval = "year"
                    @.selectPlanInterval = "month"

    backToPlans: () ->
        @.selectedPlan = false

    _onSuccessBuyPlan: (plan, amount, currency) ->
        @lightboxService.closeAll()
        @tgLoader.start()

        if !@.myPlan || (!@.myPlan.current_plan.amount_month && !@.myPlan.current_plan.amount_year)
            google_conversion_id = @config.get("google_adwords_conversion_id")
            google_conversion_label = @config.get("google_adwords_conversion_label")

            if google_conversion_id && google_conversion_label
                window.google_trackConversion({
                    google_conversion_id : google_conversion_id
                    google_conversion_language : "en",
                    google_conversion_format : "3",
                    google_conversion_color : "ffffff",
                    google_conversion_label : google_conversion_label
                    google_remarketing_only : false
                    google_conversion_value: amount
                    google_conversion_currency: currency.toUpperCase()
                })

        @subscriptionsService.selectMyPlan(plan).then(@._onSuccessSelectPlan.bind(this))


    buyPlan: () ->
        @.loadingPayments = true
        @.planId = null
        amount = null

        if @.selectPlanInterval == 'year'
            @.planId = @.validPlan.id_year
            amount = @.validPlan.amount_year
        else
            @.planId = @.validPlan.id_month
            amount = @.validPlan.amount_month

        currency = @.validPlan.currency

        @analytics.addEcStep("confirm-plan", @.myPlan?.current_plan?.plan_id, @.planId)
        @analytics.addEcProduct(@.planId, @.validPlan.name, amount)

        if @.myPlan && @.myPlan.customer_id?
            plan = {
                'plan_id': @.planId
            }

            @._onSuccessBuyPlan(plan, amount, currency)
        else
            user = @currentUserService.getUser()

            @paymentsService.start({
                description: @.validPlan.name + ' Plan',
                amount: amount,
                onLoad: () => @.loadingPayments = false
                onSuccess: (plan) =>
                    @analytics.addEcStep("plan-changed", @.myPlan?.current_plan?.plan_id, @.plan?.plan_id)
                    @analytics.addEcPurchase(@.planId, @.validPlan.name, amount)
                    @._onSuccessBuyPlan(plan, amount, currency)

                planId: @.planId,
                currency: @.validPlan.currency,
                email: user.get('email'),
                full_name: user.get('full_name')
            })

    _onSuccessSelectPlan: () ->
        message = @translate.instant("SUBSCRIPTIONS.SELECT_PLAN.SUCCESS")
        @confirm.notify('success', message, '', 5000)

        promise = @subscriptionsService.fetchMyPlans()
        promise.then () =>
            @tgLoader.pageLoaded()

module.controller("ContribLbPlansController", LightboxPlansController)
