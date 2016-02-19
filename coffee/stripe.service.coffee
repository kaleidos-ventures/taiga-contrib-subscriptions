module = angular.module('subscriptions')

class ContribStripeService
    @.$inject = []

    constructor: () ->

    start: (options) ->
        @.stripeHandler = null


        ljs.load "https://checkout.stripe.com/checkout.js", =>
            options.onLoad()

            key = 'pk_test_kAyBsE0nqnCoDMTlgpH5NB75'
            image = "/#{window._version}/images/taiga-contrib-subscriptions/images/#{options.plan.toLowerCase()}.png"
            @.stripeHandler = StripeCheckout.configure({
                key: key,
                image: image,
                locale: 'auto',
                billingAddress: false,
                panelLabel: 'Start Subscription', # LOCALIZE
                token: (data) =>
                    console.log options
                    planName = options.plan.toLowerCase()
                    planInterval = options.interval
                    params = {
                        'stripe_token': data.id
                        'plan_id': planName + '-' + planInterval
                    }

                    options.onSuccess(params)
            })

            @.stripeHandler.open({
                name: options.name,
                description: options.description,
                amount: options.amount
            })

module.service("ContribStripeService", ContribStripeService)
