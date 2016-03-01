moduleName = 'subscriptions'

window.taigaContribPlugins = [] if !window.taigaContribPlugins

window.taigaContribPlugins.push({
    type: 'userSettings',
    template: 'compile-modules/taiga-contrib-subscriptions/partials/subscriptions.html',
    name: 'Paid Plans',
    slug: 'subscriptions',
    module: moduleName,
    userMenu: true
})

angular.module(moduleName, [])
