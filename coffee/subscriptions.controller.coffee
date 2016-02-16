module = angular.module('subscriptions')

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "$translate",
        "tgLoader",
        "tgLightboxFactory",
        "lightboxService",
        "$tgConfirm"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @translate, @tgLoader, @lightboxFactory, @lightboxService, @confirm) ->
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
                token: (token) =>
                    console.log token
                    @._successBuyPlan()
            })
            @._loadStripeForm(@.validPlan)

    _loadStripeForm: (project) ->
        @.stripeHandler.open({
            name: 'Taiga',
            description: @.validPlan.name + ' Plan',
            amount: @.validPlan.amount
        })

    _successBuyPlan: () ->
        alert 'CALL API AND SEND TOKEN'
        @lightboxService.closeAll()
        @confirm.notify('success', 'OK, te has suscrito al plan correctamente', '', 5000)



module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
