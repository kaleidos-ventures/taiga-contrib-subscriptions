module = angular.module('subscriptions')

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "tgLoader",
        "lightboxService"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @tgLoader, @lightboxService) ->

    init: ->
        pluginName = "Subscriptions - User Profile - Taiga" # i18n
        @.sectionName = "Upgrade Plan"

        title = pluginName
        description = @.sectionName
        @appMetaService.setAll(title, description)

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
        @lightboxService.open('tg-lb-plans')

module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
