/// Product ids must be identical to the ones created in App Store Connect
/// and Google Play Console. Replace before shipping.
///
/// TESTING: premiumYearlyProductId is temporarily pointed at "11", the
/// single ad-hoc test subscription created in App Store Connect (still in
/// Draft as of this writing). Swap in the real monthly/yearly IDs once
/// those exist. premiumMonthlyProductId stays a placeholder for now — an
/// unresolved id is harmless, the store just won't return it.
const premiumMonthlyProductId = 'premium_monthly';
const premiumYearlyProductId = '11';

const subscriptionProductIds = {premiumMonthlyProductId, premiumYearlyProductId};
