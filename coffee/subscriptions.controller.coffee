module = angular.module('subscriptions')

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "$translate",
        "tgLoader",
        "tgLightboxFactory"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @translate, @tgLoader, @lightboxFactory) ->
        pluginName = "Subscriptions - User Profile - Taiga" # i18n
        @.sectionName = "Upgrade Plan"

        title = pluginName
        description = @.sectionName
        @appMetaService.setAll(title, description)

        @tgLoader.start()
        promise = @subscriptionsService.getMyRecommendedPlan()

        promise.then(@.onSuccess.bind(this))

    onSuccess: (response) ->
        @.yourRecommendedPlan = response
        if !@.yourRecommendedPlan
            @.plan = "paid"
            promise = @subscriptionsService.getMyPlan()
            promise.then(@._paidPlan.bind(this))
        else if @.yourRecommendedPlan.recommended_plan.amount_month == 0
            @.plan = "zero"
            @._recommendPlan(@.yourRecommendedPlan)
        else
            @.plan = "recommended"
            @._recommendPlan(@.yourRecommendedPlan)

    getTemplateUrl: () ->
        return "compile-modules/taiga-contrib-subscriptions/partials/subscriptions-"+@.plan+".html"

    _recommendPlan: (response) ->
        @tgLoader.pageLoaded()
        @.myRecommendedPlan = response

    _paidPlan: (response) ->
        @tgLoader.pageLoaded()
        @.myPlan = response
        console.log response

    upgradePlan: () ->
        promise = @subscriptionsService.getPublicPlans()
        @.loading = true
        promise.then(@._plansList.bind(this))

    _plansList: (response) ->
        @.loading = false
        @.selectedPlan = false
        lbScope = {
            response: response,
            myPlan : @.myPlan,
            myRecommendedPlan: @.myRecommendedPlan
        }
        @lightboxFactory.create("tg-lb-plans", {
            "class": "lightbox lightbox-plans lightbox-generic-form"
        }, lbScope)

    selectPLan: (project) ->
        if !project.is_applicable
            @.selectedPlan = 'invalid'
            @.invalidPlan = project
        else
            @.selectedPlan = 'valid'
            @.validPlan = project

    backToPLans: () ->
        @.selectedPlan = false

    buyPlan: (project) ->
        @.stripeHandler = null
        ljs.load "https://checkout.stripe.com/checkout.js", =>
            @.stripeHandler = StripeCheckout.configure({
                key: 'pk_test_kAyBsE0nqnCoDMTlgpH5NB75',
                image: '/logo-color.png',
                locale: 'auto',
                billingAddress: false,
                panelLabel: 'Start Subscription',
                token: (token) ->
                    console.log token
            })
            @._loadStripeForm(project)

    _loadStripeForm: (project) ->
        console.log @.validPlan
        @.stripeHandler.open({
            name: 'Taiga Project Management',
            description: @.validPlan.name,
            amount: @.validPlan.amount
        })

module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
