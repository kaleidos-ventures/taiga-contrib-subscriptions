module = angular.module('subscriptions')

class LightboxPlansController
    @.$inject = [
        "ContribSubscriptionsService",
        "$translate",
        "tgLoader",
        "$tgConfirm",
        "lightboxService"
    ]

    constructor: (@subscriptionsService, @translate, @tgLoader, @confirm, @lightboxService) ->
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

    buyPlan: () ->
        @.stripeHandler = null
        @.loadingStripe = true
        ljs.load "https://checkout.stripe.com/checkout.js", =>
            @.loadingStripe = false
            key = 'pk_test_kAyBsE0nqnCoDMTlgpH5NB75'
            image = "/#{window._version}/images/taiga-contrib-subscriptions/images/#{@.validPlan.name.toLowerCase()}.png"
            @.stripeHandler = StripeCheckout.configure({
                key: key,
                image: image,
                locale: 'auto',
                billingAddress: false,
                panelLabel: 'Start Subscription',
                token: (data) =>
                    planName = @.validPlan.name.toLowerCase()
                    planInterval = @.selectPlanInterval
                    params = {
                        'stripe_token': data.id
                        'plan_id': planName + '-' + planInterval
                    }
                    promise = @subscriptionsService.selectMyPlan(params)
                    @tgLoader.start()
                    promise.then(@._successBuyPlan())
            })
            @._loadStripeForm(@.validPlan)

    _loadStripeForm: () ->
        @.stripeHandler.open({
            name: 'Taiga',
            description: @.validPlan.name + ' Plan',
            amount: @.validPlan.amount
        })

    _successBuyPlan: () ->
        @lightboxService.closeAll()
        @confirm.notify('success', 'OK, te has suscrito al plan correctamente', '', 5000)

        promise = @subscriptionsService.fetchMyPlans()
        promise.then () => @tgLoader.pageLoaded()

module.controller("ContribLbPlansController", LightboxPlansController)
