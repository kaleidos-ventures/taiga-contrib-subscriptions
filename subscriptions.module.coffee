moduleName = 'subscriptions'

window.taigaContribPlugins = [] if !window.taigaContribPlugins

window.taigaContribPlugins.push({
    type: 'userSettings',
    template: 'compile-modules/taiga-contrib-subscriptions/partials/subscriptions.html',
    name: 'Subscriptions',
    slug: 'subscriptions',
    module: moduleName
})

angular.module(moduleName, [])
