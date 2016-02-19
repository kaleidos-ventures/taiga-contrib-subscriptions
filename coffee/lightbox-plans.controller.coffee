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
