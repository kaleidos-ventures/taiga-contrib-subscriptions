module = angular.module('subscriptions')

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "tgLoader",
        "lightboxService",
        "$translatePartialLoader",
        "$translate"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @tgLoader, @lightboxService, @translatePartialLoader, @translate) ->
        @translatePartialLoader.addPart('taiga-contrib-subscriptions')

    init: ->
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
        @.sectionName = @translate.instant("SUBSCRIPTIONS.TITLE")
        description = @translate.instant("SUBSCRIPTIONS.SECTION_NAME")

        @appMetaService.setAll(@.sectionName, description)

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
