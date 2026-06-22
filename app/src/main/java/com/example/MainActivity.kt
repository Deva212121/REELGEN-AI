package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.MyApplicationTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// Color Scheme Constants for Immersive UI Theme (Material 3 Dark Variant)
val SlateBg = Color(0xFF1C1B1F)       // Deep immersive primary darkness
val CardSlate = Color(0xFF2B2930)     // Premium dark container charcoal background
val CardBorderColor = Color(0xFF49454F)// Border divider accent for containers
val ElectricBlue = Color(0xFFD0BCFF)  // Light premium lavender/purple accent
val NeonCoral = Color(0xFF381E72)     // Deep dramatic royal purple
val LightAccent = Color(0xFF938F99)   // Muted slate gray for secondary labels
val EmeraldGreen = Color(0xFFC4FF62)  // High-contrast neon lime for positive tracking highlights

enum class WorkspaceRole {
    INFLUENCER, VENDOR, ADMIN
}

// Custom simulated Firestore collection models
data class ProductPromotion(
    val id: String,
    val influencerId: String,
    val vendorId: String,
    val productId: String,
    val productName: String,
    val approvalOtp: String,
    val otpVerified: Boolean,
    val status: String // "PENDING", "APPROVED", "VERIFIED"
)

data class AffiliateLink(
    val id: String,
    val influencerId: String,
    val vendorId: String,
    val productId: String,
    val productName: String,
    val referralCode: String,
    val trackingLink: String,
    val totalClicks: Int = 0,
    val totalOrders: Int = 0,
    val totalBusiness: Double = 0.0
)

data class PromoProduct(
    val id: String,
    val name: String,
    val category: String,
    val vendorId: String,
    val payoutModel: String
)

object FirestoreDb {
    val sampleProducts = listOf(
        PromoProduct("prod_hydrate", "Super Hydrate Serum", "Skincare", "vend_aqua", "15% Commission (Est: $4.50/click)"),
        PromoProduct("prod_peaks", "Peak Nutrition Bites", "Food & Beverage", "vend_nutri", "12% Commission (Est: $2.10/order)"),
        PromoProduct("prod_sonic", "Sonic Sound Waves XL", "Audio & Gadgets", "vend_sound", "10% Commission (Est: $15.00/order)"),
        PromoProduct("prod_earbuds", "ReelGen Premium Earbuds", "Electronics", "vend_reelgen", "20% Commission (Est: $19.99/order)")
    )

    val product_promotions = mutableStateListOf<ProductPromotion>(
        // Seed two startup documents to offer instant user interaction
        ProductPromotion(
            id = "promo_7281",
            influencerId = "@active_creator",
            vendorId = "vend_aqua",
            productId = "prod_hydrate",
            productName = "Super Hydrate Serum",
            approvalOtp = "483920",
            otpVerified = false,
            status = "APPROVED" // Approved by brand: waiting for Influencer OTP verification
        ),
        ProductPromotion(
            id = "promo_9481",
            influencerId = "@active_creator",
            vendorId = "vend_nutri",
            productId = "prod_peaks",
            productName = "Peak Nutrition Bites",
            approvalOtp = "",
            otpVerified = false,
            status = "PENDING" // Freshly created: waiting for Vendor approval
        )
    )

    val affiliate_links = mutableStateListOf<AffiliateLink>()

    val dbTransactions = mutableStateListOf<String>(
        "Firestore initialized at UTC 2026-05-30.",
        "Collection 'product_promotions' seeded with 2 initial documents.",
        "Collection 'affiliate_links' initialized with 0 documents."
    )

    fun log(message: String) {
        dbTransactions.add(0, "[Firestore Log] $message")
    }

    fun createPromotionRequest(influencerId: String, product: PromoProduct): ProductPromotion {
        val newId = "promo_${(1000..9999).random()}"
        val request = ProductPromotion(
            id = newId,
            influencerId = influencerId,
            vendorId = product.vendorId,
            productId = product.id,
            productName = product.name,
            approvalOtp = "", // Wait for approval
            otpVerified = false,
            status = "PENDING"
        )
        product_promotions.add(request)
        log("CREATE document in 'product_promotions' collection (ID: $newId)")
        return request
    }

    fun approvePromotionRequest(id: String): String {
        val index = product_promotions.indexOfFirst { it.id == id }
        if (index != -1) {
            val req = product_promotions[index]
            val generatedOtp = (100000..999999).random().toString()
            val updated = req.copy(
                approvalOtp = generatedOtp,
                status = "APPROVED"
            )
            product_promotions[index] = updated
            log("UPDATE document ID: $id in 'product_promotions' -> status='APPROVED', approvalOtp='$generatedOtp'")
            return generatedOtp
        }
        return ""
    }

    fun verifyPromotionOtp(promoId: String, otpInput: String): Boolean {
        val index = product_promotions.indexOfFirst { it.id == promoId }
        if (index != -1) {
            val req = product_promotions[index]
            if (req.approvalOtp == otpInput && !req.otpVerified) {
                // Mark OTP as verified
                val updated = req.copy(
                    otpVerified = true,
                    status = "VERIFIED"
                )
                product_promotions[index] = updated
                log("UPDATE document ID: $promoId in 'product_promotions' -> otpVerified=true, status='VERIFIED'")

                // Automatically formulate affiliate_links document schema
                val referralCode = "RG-${req.productName.take(3).uppercase()}-${(100..999).random()}"
                val trackingLink = "https://reelgen.ai/promote/${req.productId}?ref=$referralCode"

                val newAffId = "aff_${(1000..9999).random()}"
                val affiliateRecord = AffiliateLink(
                    id = newAffId,
                    influencerId = req.influencerId,
                    vendorId = req.vendorId,
                    productId = req.productId,
                    productName = req.productName,
                    referralCode = referralCode,
                    trackingLink = trackingLink
                )
                affiliate_links.add(affiliateRecord)
                log("CREATE document in 'affiliate_links' collection (ID: $newAffId) with Referral Code: $referralCode")
                return true
            }
        }
        return false
    }

    fun simulateAffiliateMetrics(affId: String, clicks: Int, orders: Int, revenue: Double) {
        val index = affiliate_links.indexOfFirst { it.id == affId }
        if (index != -1) {
            val current = affiliate_links[index]
            val updated = current.copy(
                totalClicks = current.totalClicks + clicks,
                totalOrders = current.totalOrders + orders,
                totalBusiness = current.totalBusiness + revenue
            )
            affiliate_links[index] = updated
            log("UPDATE document ID: $affId in 'affiliate_links' -> Clicks=${updated.totalClicks}, Orders=${updated.totalOrders}, Revenue=$${String.format("%.2f", updated.totalBusiness)}")
        }
    }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                ReelGeneratorWorkspace()
            }
        }
    }
}

@Composable
fun ReelGeneratorWorkspace() {
    var activeRole by remember { mutableStateOf(WorkspaceRole.INFLUENCER) }
    var selectedModule by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()

    Scaffold(
        modifier = Modifier
            .fillMaxSize()
            .drawBehind {
                drawRect(
                    brush = Brush.verticalGradient(
                        colors = listOf(SlateBg, Color(0xFF030712))
                    )
                )
            },
        containerColor = Color.Transparent,
        topBar = {
            Column(modifier = Modifier.statusBarsPadding()) {
                HeaderBrandBar()
                RoleSelectorBar(selectedRole = activeRole, onRoleSelected = { activeRole = it })
            }
        },
        bottomBar = {
            BottomAppSignature()
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            // Animated layout switch depending on the selected role
            AnimatedContent(
                targetState = activeRole,
                transitionSpec = {
                    fadeIn(animationSpec = tween(300)) togetherWith fadeOut(animationSpec = tween(200))
                },
                label = "dashboard_swap"
            ) { role ->
                when (role) {
                    WorkspaceRole.INFLUENCER -> InfluencerDashboardView(
                        onSelectModule = { selectedModule = it }
                    )
                    WorkspaceRole.VENDOR -> VendorDashboardView(
                        onSelectModule = { selectedModule = it }
                    )
                    WorkspaceRole.ADMIN -> AdminDashboardView(
                        onSelectModule = { selectedModule = it }
                    )
                }
            }

            // Centralized Modal Overlays to Interactively Demonstrate all 11 unique task screens
            selectedModule?.let { module ->
                ModuleDetailDialog(
                    moduleName = module,
                    onDismiss = { selectedModule = null }
                )
            }
        }
    }
}

@Composable
fun HeaderBrandBar() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            // Rounded logo icon wrapper matching HTML bg-[#D0BCFF] text-[#381E72]
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(ElectricBlue),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.PlayArrow,
                    contentDescription = "Logo icon",
                    tint = NeonCoral, // #381E72
                    modifier = Modifier.size(22.dp)
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            Column {
                Text(
                    text = "ReelGen AI",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    letterSpacing = 0.5.sp
                )
                Text(
                    text = "INFLUENCER PRO",
                    fontSize = 10.sp,
                    color = ElectricBlue, // #D0BCFF accent
                    fontWeight = FontWeight.Black,
                    letterSpacing = 1.sp
                )
            }
        }

        // Circular profile mockup with visual border gradient
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .border(2.dp, ElectricBlue, CircleShape)
                .padding(2.dp)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            colors = listOf(ElectricBlue, NeonCoral)
                        )
                    )
            )
        }
    }
}

@Composable
fun RoleSelectorBar(selectedRole: WorkspaceRole, onRoleSelected: (WorkspaceRole) -> Unit) {
    ScrollableRow(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        WorkspaceRole.values().forEach { role ->
            val isSelected = selectedRole == role
            val outlineColor = if (isSelected) ElectricBlue else CardBorderColor
            val surfaceBg = if (isSelected) CardSlate else Color(0x332B2930)
            val textAccent = if (isSelected) ElectricBlue else LightAccent
            val iconImage = when (role) {
                WorkspaceRole.INFLUENCER -> Icons.Default.Person
                WorkspaceRole.VENDOR -> Icons.Default.Home
                WorkspaceRole.ADMIN -> Icons.Default.Settings
            }

            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(surfaceBg)
                    .border(1.dp, outlineColor, RoundedCornerShape(12.dp))
                    .clickable { onRoleSelected(role) }
                    .padding(horizontal = 16.dp, vertical = 10.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = iconImage,
                        contentDescription = role.name,
                        tint = textAccent,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = when (role) {
                            WorkspaceRole.INFLUENCER -> "Influencer Workspace"
                            WorkspaceRole.VENDOR -> "Vendor Workspace"
                            WorkspaceRole.ADMIN -> "Admin Console"
                        },
                        color = if (isSelected) Color.White else LightAccent,
                        fontSize = 12.sp,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                    )
                }
            }
        }
    }
}

@Composable
fun ScrollableRow(
    modifier: Modifier = Modifier,
    horizontalArrangement: Arrangement.Horizontal = Arrangement.Start,
    content: @Composable RowScope.() -> Unit
) {
    Row(
        modifier = modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = horizontalArrangement,
        verticalAlignment = Alignment.CenterVertically,
        content = content
    )
}

@Composable
fun BottomAppSignature() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(bottom = 12.dp, top = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "reel_generator enterprise engine - preview v1.0",
            color = LightAccent.copy(alpha = 0.5f),
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

// ------------------------------------
// INFLUENCER WORKSPACE VIEW
// ------------------------------------
@Composable
fun InfluencerDashboardView(onSelectModule: (String) -> Unit) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            QuickSummaryBanner(
                title = "Welcome, Creator!",
                subtitle = "Generate custom advertising copies, animate frames into short reels, and scale brand promotions smoothly.",
                primaryColor = NeonCoral
            )
        }

        item {
            SectionHeader(title = "Creative Reels AI Engines")
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "AI Script Generator",
                        desc = "Develop optimized hooks & speech",
                        icon = Icons.Default.Create,
                        badge = "Gemini",
                        accent = ElectricBlue,
                        onClick = { onSelectModule("AI Script Generator") }
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Voice Upload",
                        desc = "Provide voice clones instantly",
                        icon = Icons.Default.Send,
                        badge = "Storage",
                        accent = NeonCoral,
                        onClick = { onSelectModule("Voice Upload") }
                    )
                }
            }
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Image to Video UI",
                        desc = "Render images into motions",
                        icon = Icons.Default.Refresh,
                        badge = "Creative",
                        accent = EmeraldGreen,
                        onClick = { onSelectModule("Image To Video UI") }
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Reel Preview",
                        desc = "Cinematic scroll previewer",
                        icon = Icons.Default.PlayArrow,
                        badge = "Player",
                        accent = Color(0xFFA855F7),
                        onClick = { onSelectModule("Reel Preview") }
                    )
                }
            }
        }

        item {
            SectionHeader(title = "Business & Analytics")
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Product Promo Requests",
                        desc = "Select products & submit brief requests",
                        icon = Icons.Default.Search,
                        badge = "Firestore",
                        accent = Color(0xFFF59E0B),
                        onClick = { onSelectModule("Product Promotion Requests") }
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Reel Performance Tracking",
                        desc = "Social reach graphs & count",
                        icon = Icons.Default.Info,
                        badge = "Charts",
                        accent = Color(0xFF22C55E),
                        onClick = { onSelectModule("Reel Tracking") }
                    )
                }
            }
        }
 
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "OTP Promo Verification",
                        desc = "Enter active OTP keys of brand campaign",
                        icon = Icons.Default.Lock,
                        badge = "Secure",
                        accent = Color(0xFFE11D48),
                        onClick = { onSelectModule("OTP Verification Screen") }
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Influencer Business KPIs",
                        desc = "Contracts lists & trends",
                        icon = Icons.Default.Menu,
                        badge = "Contracts",
                        accent = Color(0xFF06B6D4),
                        onClick = { onSelectModule("Influencer Business Tracking") }
                    )
                }
            }
        }

        item { Spacer(modifier = Modifier.height(20.dp)) }
    }
}

// ------------------------------------
// VENDOR WORKSPACE VIEW
// ------------------------------------
@Composable
fun VendorDashboardView(onSelectModule: (String) -> Unit) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            QuickSummaryBanner(
                title = "Welcome, Business Brand!",
                subtitle = "Promote products on the platform, authorize influencer briefs, and secure contracts via verification.",
                primaryColor = ElectricBlue
            )
        }

        item {
            SectionHeader(title = "Brand Campaign Portals")
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Own Product Upload",
                        desc = "List items for matching pools",
                        icon = Icons.Default.Add,
                        badge = "New",
                        accent = EmeraldGreen,
                        onClick = { onSelectModule("Own Product Upload") }
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Security OTP Verification",
                        desc = "Confirm promotional contracts",
                        icon = Icons.Default.Lock,
                        badge = "Secure",
                        accent = Color(0xFFF59E0B),
                        onClick = { onSelectModule("Product Promotion OTP Verification") }
                    )
                }
            }
        }

        item {
            SectionHeader(title = "Direct Performance Insights")
        }

        item {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(CardSlate)
                    .padding(20.dp)
            ) {
                Column {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Matching Dashboard Status",
                            color = Color.White,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(10.dp))
                                .background(Color(0xFF059669).copy(alpha = 0.2f))
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Text(
                                text = "Running Pool",
                                color = EmeraldGreen,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                    Spacer(modifier = Modifier.height(16.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        MetricBox(
                            title = "Active Campaigns",
                            value = "24",
                            subtitle = "+2 this week",
                            modifier = Modifier.weight(1f)
                        )
                        MetricBox(
                            title = "Influencer Pitch Matches",
                            value = "118",
                            subtitle = "84% response rate",
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }

        item { Spacer(modifier = Modifier.height(20.dp)) }
    }
}

// ------------------------------------
// ADMIN WORKSPACE VIEW
// ------------------------------------
@Composable
fun AdminDashboardView(onSelectModule: (String) -> Unit) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            QuickSummaryBanner(
                title = "Platform Admin Control",
                subtitle = "Coordinate matching logs, register user roles, authorize models and supervise verification.",
                primaryColor = Color(0xFFA855F7)
            )
        }

        item {
            SectionHeader(title = "Supervisory Functions")
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Verify Promotion Status",
                        desc = "Check system transactions",
                        icon = Icons.Default.Check,
                        badge = "Secure",
                        accent = Color(0xFFF59E0B),
                        onClick = { onSelectModule("Product Promotion OTP Verification") }
                    )
                }
                Box(modifier = Modifier.weight(1f)) {
                    ModuleLaunchCard(
                        title = "Admin Dashboard Controls",
                        desc = "Control platform algorithms",
                        icon = Icons.Default.Settings,
                        badge = "Admin Only",
                        accent = Color(0xFFE11D48),
                        onClick = { onSelectModule("Admin Dashboard") }
                    )
                }
            }
        }

        item {
            SectionHeader(title = "Platform Global KPIs")
        }

        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(CardSlate)
                    .padding(18.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                KPIProgressLine(label = "Influencer Active Enrolments", percent = 0.82f, color = NeonCoral)
                KPIProgressLine(label = "AI video clips generated / day", percent = 0.65f, color = ElectricBlue)
                KPIProgressLine(label = "Vendor promotional allocations", percent = 0.44f, color = EmeraldGreen)
            }
        }

        item { Spacer(modifier = Modifier.height(20.dp)) }
    }
}

// ------------------------------------
// SUB-COMPONENTS & UTILS
// ------------------------------------
@Composable
fun QuickSummaryBanner(title: String, subtitle: String, primaryColor: Color) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(26.dp))
            .background(
                Brush.linearGradient(
                    colors = listOf(NeonCoral, CardBorderColor) // Gradient from deep purple (#381E72) to card border slate (#49454F) 
                )
            )
            .border(
                1.dp,
                ElectricBlue.copy(alpha = 0.25f), // subtle glowing border
                RoundedCornerShape(26.dp)
            )
            .padding(20.dp)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            // Little sparkling badge matching auto_awesome tag in HTML
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Star,
                    contentDescription = null,
                    tint = ElectricBlue,
                    modifier = Modifier.size(12.dp)
                )
                Text(
                    text = "REELGEN INTERACTIVITY",
                    color = ElectricBlue,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                )
            }
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = title,
                fontSize = 20.sp,
                fontWeight = FontWeight.Light,
                color = Color.White
            )
            Text(
                text = subtitle,
                fontSize = 12.sp,
                color = LightAccent,
                lineHeight = 18.sp
            )
        }
    }
}

@Composable
fun SectionHeader(title: String) {
    Text(
        text = title,
        color = Color.White,
        fontSize = 14.sp,
        fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(vertical = 4.dp)
    )
}

@Composable
fun ModuleLaunchCard(
    title: String,
    desc: String,
    icon: ImageVector,
    badge: String,
    accent: Color,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .border(1.dp, CardBorderColor, RoundedCornerShape(18.dp)) // border line matching HTML border-[#49454F]
            .clickable { onClick() },
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = CardSlate)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(CardBorderColor), // matching bg-[#49454F] in HTML
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = icon,
                        contentDescription = title,
                        tint = ElectricBlue, // matching text-[#D0BCFF] in HTML
                        modifier = Modifier.size(18.dp)
                    )
                }

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color.White.copy(alpha = 0.05f))
                        .padding(horizontal = 8.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = badge,
                        color = ElectricBlue,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }

            Text(
                text = title,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Text(
                text = desc,
                fontSize = 11.sp,
                color = LightAccent, // matching text-[#938F99] in HTML
                lineHeight = 14.sp,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
fun MetricBox(title: String, value: String, subtitle: String, modifier: Modifier) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(SlateBg)
            .border(1.dp, CardBorderColor, RoundedCornerShape(12.dp))
            .padding(12.dp)
    ) {
        Column {
            Text(text = title, color = LightAccent, fontSize = 11.sp)
            Spacer(modifier = Modifier.height(4.dp))
            Text(text = value, color = Color.White, fontSize = 20.sp, fontWeight = FontWeight.Black)
            Spacer(modifier = Modifier.height(2.dp))
            Text(text = subtitle, color = EmeraldGreen, fontSize = 9.sp, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
fun KPIProgressLine(label: String, percent: Float, color: Color) {
    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(text = label, color = LightAccent, fontSize = 11.sp)
            Text(text = "${(percent * 100).toInt()}%", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        }
        Spacer(modifier = Modifier.height(6.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(CircleShape)
                .background(SlateBg)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(percent)
                    .clip(CircleShape)
                    .background(color)
            )
        }
    }
}

// ------------------------------------
// INTERACTIVE MODULE MODALS
// ------------------------------------
@Composable
fun ModuleDetailDialog(moduleName: String, onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            Button(
                onClick = onDismiss,
                colors = ButtonDefaults.buttonColors(containerColor = ElectricBlue)
            ) {
                Text(text = "Close Shell", fontWeight = FontWeight.Bold)
            }
        },
        title = {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(30.dp)
                        .clip(CircleShape)
                        .background(ElectricBlue.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Info,
                        contentDescription = "info",
                        tint = ElectricBlue,
                        modifier = Modifier.size(16.dp)
                    )
                }
                Text(
                    text = moduleName,
                    fontSize = 16.sp,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
            }
        },
        text = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 400.dp)
            ) {
                when (moduleName) {
                    "AI Script Generator" -> InteractiveScriptGenerator()
                    "Voice Upload" -> VoiceUploadWorkshop()
                    "Image To Video UI" -> ImageToVideoRenderer()
                    "Reel Preview" -> LiveReelPlayer()
                    "Product Promotion Requests" -> ProductPromotionRequestScreen()
                    "Own Product Upload" -> ProductSubmission()
                    "OTP Verification Screen" -> OtpVerificationScreen()
                    "Product Promotion OTP Verification" -> VendorPromotionManager()
                    "Reel Tracking" -> AnalyticalReelsTracker()
                    "Avatar Clone Placeholder" -> ConfigurationAvatarClone()
                    "Influencer Business Tracking" -> BusinessInvoicingTracking()
                    "Admin Dashboard" -> SuperuserControls()
                    else -> Text(text = "Placeholder for $moduleName dashboard configurations", color = LightAccent)
                }
            }
        },
        containerColor = CardSlate,
        shape = RoundedCornerShape(24.dp)
    )
}

// 1. AI Script Generator
@Composable
fun InteractiveScriptGenerator() {
    var rawInput by remember { mutableStateOf("") }
    var generatedResults by remember { mutableStateOf<List<String>>(emptyList()) }
    var isCompiling by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Generate commercial hooks and ad scripts for targeting key customer demographics.",
            color = LightAccent,
            fontSize = 11.sp,
            lineHeight = 16.sp
        )

        OutlinedTextField(
            value = rawInput,
            onValueChange = { rawInput = it },
            placeholder = { Text(text = "e.g., Slim Fit Protein Shake", color = LightAccent, fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            maxLines = 2,
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = LightAccent,
                focusedBorderColor = ElectricBlue,
                unfocusedBorderColor = LightAccent.copy(alpha = 0.3f)
            )
        )

        Button(
            onClick = {
                scope.launch {
                    isCompiling = true
                    delay(1200)
                    generatedResults = listOf(
                        "🔥 Hook: \"Think all protein shakes are chalky? Try this dynamic slim shake...\"",
                        "🌟 Body: \"Made with organic pea protein, keeping you fully energized without any artificial bloating!\"",
                        "📢 Action: \"Tap now to claim 20% off plus free express shipping!\""
                    )
                    isCompiling = false
                }
            },
            enabled = rawInput.isNotBlank() && !isCompiling,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = NeonCoral)
        ) {
            if (isCompiling) {
                CircularProgressIndicator(modifier = Modifier.size(20.dp), color = Color.White, strokeWidth = 2.dp)
            } else {
                Text(text = "Synthesize AI Script", fontWeight = FontWeight.Bold)
            }
        }

        if (generatedResults.isNotEmpty()) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFF0F172A))
                    .padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                generatedResults.forEach { line ->
                    Text(text = line, color = Color.White, fontSize = 11.sp, lineHeight = 16.sp)
                }
            }
        }
    }
}

// 2. Voice Upload
@Composable
fun VoiceUploadWorkshop() {
    var isUploading by remember { mutableStateOf(false) }
    var uploadedCount by remember { mutableStateOf(0) }
    var durationCount by remember { mutableStateOf(0) }
    val scope = rememberCoroutineScope()

    Column(verticalArrangement = Arrangement.spacedBy(12.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = "Record dynamic voice clone patterns or launch storage transfers to back active reels.",
            color = LightAccent,
            fontSize = 11.sp,
            textAlign = TextAlign.Center
        )

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(Color(0xFF0F172A))
                .border(1.dp, LightAccent.copy(alpha = 0.2f), RoundedCornerShape(16.dp))
                .padding(20.dp),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = "waveform",
                    tint = NeonCoral,
                    modifier = Modifier.size(28.dp)
                )

                Text(
                    text = if (isUploading) "Securing Stream Transfer..." else "Sample Voice Input: (Recorded clips: $uploadedCount)",
                    color = Color.White,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )

                if (isUploading) {
                    LinearProgressIndicator(color = ElectricBlue, trackColor = Color(0x2238BDF8), modifier = Modifier.fillMaxWidth())
                }
            }
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(
                onClick = {
                    scope.launch {
                        isUploading = true
                        delay(1500)
                        uploadedCount += 1
                        isUploading = false
                    }
                },
                enabled = !isUploading,
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = CardSlate)
            ) {
                Text(text = "Mock Upload Clip", fontSize = 11.sp, color = Color.White)
            }

            Button(
                onClick = { },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen)
            ) {
                Text(text = "Begin Recording", fontSize = 11.sp)
            }
        }
    }
}

// 3. Image to Video UI
@Composable
fun ImageToVideoRenderer() {
    val templates = listOf("Cyberpunk Shoes", "Eco Kettle Brand", "Polarized Shades")
    var selectedTemplate by remember { mutableStateOf(templates[0]) }
    var renderProgress by remember { mutableStateOf(0f) }
    var renderComplete by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(
            text = "Select high-res visual catalog slides to synthesize automated panning reel renders.",
            color = LightAccent,
            fontSize = 11.sp
        )

        ScrollableRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            templates.forEach { temp ->
                val active = selectedTemplate == temp
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(if (active) ElectricBlue else Color(0xFF0F172A))
                        .clickable { selectedTemplate = temp }
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Text(text = temp, color = if (active) Color.Black else Color.White, fontSize = 11.sp)
                }
            }
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(110.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(Color(0xFF0F172A)),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = if (renderComplete) "✅ Synthesis Complete!" else "Aesthetic Style: $selectedTemplate",
                    color = Color.White,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )

                if (renderProgress > 0f) {
                    Box(modifier = Modifier.width(180.dp)) {
                        LinearProgressIndicator(
                            progress = { renderProgress },
                            color = EmeraldGreen,
                            trackColor = Color(0x2210B981),
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }
        }

        Button(
            onClick = {
                scope.launch {
                    renderComplete = false
                    renderProgress = 0.05f
                    while (renderProgress < 1f) {
                        delay(120)
                        renderProgress += 0.15f
                    }
                    renderProgress = 1f
                    renderComplete = true
                }
            },
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = NeonCoral)
        ) {
            Text(text = "Trigger Video Synthesizer", fontWeight = FontWeight.Bold)
        }
    }
}

// 4. Live Reel Preview
@Composable
fun LiveReelPlayer() {
    var likeCount by remember { mutableStateOf(104) }
    var isLiked by remember { mutableStateOf(false) }

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Live cinematic viewport mock representing end-user application render layout.",
            color = LightAccent,
            fontSize = 11.sp
        )

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(Color.Black),
            contentAlignment = Alignment.BottomStart
        ) {
            // Simulated video content drawn with dynamic canvas elements
            Canvas(modifier = Modifier.fillMaxSize()) {
                drawCircle(
                    color = ElectricBlue.copy(alpha = 0.2f),
                    radius = 240f,
                    center = Offset(size.width / 2, size.height / 2)
                )
            }

            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(14.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Bottom
            ) {
                Column(modifier = Modifier.weight(0.7f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(24.dp)
                                .clip(CircleShape)
                                .background(NeonCoral)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(text = "@active_creator", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                    Text(
                        text = "This organic product changed my health metrics over standard shake lines! 🔥 #organic #fit",
                        color = Color.White,
                        fontSize = 10.sp,
                        lineHeight = 14.sp,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                Column(
                    modifier = Modifier.weight(0.3f),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    IconButton(
                        onClick = {
                            isLiked = !isLiked
                            if (isLiked) likeCount++ else likeCount--
                        },
                        modifier = Modifier.background(Color.Black.copy(alpha = 0.5f), CircleShape)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Favorite,
                            contentDescription = "like icon",
                            tint = if (isLiked) NeonCoral else Color.White,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Text(text = "$likeCount Likes", color = Color.White, fontSize = 9.sp)
                }
            }
        }
    }
}

// 5. Product Promotion Request Screen
@Composable
fun ProductPromotionRequestScreen() {
    var influencerIdInput by remember { mutableStateOf("@active_creator") }
    var selectedProductIndex by remember { mutableStateOf(0) }
    var showSuccessMessage by remember { mutableStateOf<String?>(null) }

    LazyColumn(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(14.dp),
        contentPadding = PaddingValues(vertical = 4.dp)
    ) {
        item {
            Text(
                text = "Launch brand sponsorships instantly. Select products to submit promotion proposals directly into our Firestore 'product_promotions' collection.",
                color = LightAccent,
                fontSize = 11.sp,
                lineHeight = 15.sp
            )
        }

        item {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(text = "Influencer Handle / ID", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                OutlinedTextField(
                    value = influencerIdInput,
                    onValueChange = { influencerIdInput = it },
                    placeholder = { Text(text = "e.g., @active_creator", color = LightAccent, fontSize = 12.sp) },
                    modifier = Modifier.fillMaxWidth(),
                    maxLines = 1,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedBorderColor = ElectricBlue,
                        unfocusedBorderColor = CardBorderColor
                    )
                )
            }
        }

        item {
            Text(text = "Choose Product for Campaign", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        }

        items(FirestoreDb.sampleProducts.size) { idx ->
            val product = FirestoreDb.sampleProducts[idx]
            val isSelected = selectedProductIndex == idx
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(if (isSelected) CardBorderColor.copy(alpha = 0.4f) else Color(0x332B2930))
                    .border(1.dp, if (isSelected) ElectricBlue else CardBorderColor, RoundedCornerShape(12.dp))
                    .clickable { selectedProductIndex = idx }
                    .padding(12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(0.7f)) {
                    Text(text = product.name, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    Text(text = "Category: ${product.category}", color = LightAccent, fontSize = 10.sp)
                    Text(text = "Payout: ${product.payoutModel}", color = EmeraldGreen, fontSize = 10.sp, fontWeight = FontWeight.Medium)
                }
                RadioButton(
                    selected = isSelected,
                    onClick = { selectedProductIndex = idx },
                    colors = RadioButtonDefaults.colors(selectedColor = ElectricBlue, unselectedColor = LightAccent)
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
        }

        item {
            Button(
                onClick = {
                    val p = FirestoreDb.sampleProducts[selectedProductIndex]
                    val req = FirestoreDb.createPromotionRequest(influencerIdInput, p)
                    showSuccessMessage = "Promotion request submitted for ${p.name}! (Doc ID: ${req.id}). Go to Vendor tab to approve it & generate the 6-digit OTP."
                },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(containerColor = NeonCoral)
            ) {
                Icon(Icons.Default.Add, contentDescription = null, tint = Color.White, modifier = Modifier.size(16.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text(text = "Create Promotion Request", fontWeight = FontWeight.Bold, fontSize = 12.sp)
            }
        }

        showSuccessMessage?.let { msg ->
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(10.dp))
                        .background(EmeraldGreen.copy(alpha = 0.12f))
                        .border(1.dp, EmeraldGreen, RoundedCornerShape(10.dp))
                        .padding(10.dp)
                ) {
                    Text(text = msg, color = Color.White, fontSize = 11.sp, lineHeight = 14.sp)
                }
            }
        }

        item {
            Spacer(modifier = Modifier.height(8.dp))
            FirestoreCollectionViewer(
                collectionName = "product_promotions",
                documents = FirestoreDb.product_promotions.toList()
            )
        }
    }
}

// Reusable Firestore Visualizer console to satisfy full collection specification
@Composable
fun <T : Any> FirestoreCollectionViewer(collectionName: String, documents: List<T>) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFF0F172A))
            .border(1.dp, CardBorderColor, RoundedCornerShape(12.dp))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(Color(0xFFF15A24)) // Orange Firestore brand indicator
                )
                Text(
                    text = "cloud_firestore console",
                    fontFamily = FontFamily.Monospace,
                    fontSize = 11.sp,
                    color = LightAccent,
                    fontWeight = FontWeight.Bold
                )
            }
            Text(
                text = "/${collectionName}",
                color = ElectricBlue,
                fontSize = 10.sp,
                fontFamily = FontFamily.Monospace,
                fontWeight = FontWeight.Bold
            )
        }

        Divider(color = CardBorderColor.copy(alpha = 0.4f), modifier = Modifier.padding(vertical = 2.dp))

        if (documents.isEmpty()) {
            Text(
                text = "Collection is empty. Documents will dynamically display here.",
                color = LightAccent,
                fontSize = 10.sp,
                fontFamily = FontFamily.Monospace
            )
        } else {
            documents.forEach { doc ->
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(6.dp))
                        .background(Color(0xFF090D16))
                        .padding(8.dp)
                ) {
                    Text(
                        text = formatDocumentJson(doc),
                        color = Color(0xFFA5F3FC), // cyan syntax highlight
                        fontSize = 9.sp,
                        fontFamily = FontFamily.Monospace,
                        lineHeight = 12.sp
                    )
                }
            }
        }
    }
}

// Formatter to render clean JSON representation of Firestore records
fun formatDocumentJson(doc: Any): String {
    return when (doc) {
        is ProductPromotion -> {
            """{
  "id": "${doc.id}",
  "influencerId": "${doc.influencerId}",
  "vendorId": "${doc.vendorId}",
  "productId": "${doc.productId}",
  "productName": "${doc.productName}",
  "approvalOtp": "${doc.approvalOtp}",
  "otpVerified": ${doc.otpVerified},
  "status": "${doc.status}"
}"""
        }
        is AffiliateLink -> {
            """{
  "id": "${doc.id}",
  "influencerId": "${doc.influencerId}",
  "vendorId": "${doc.vendorId}",
  "productId": "${doc.productId}",
  "productName": "${doc.productName}",
  "referralCode": "${doc.referralCode}",
  "trackingLink": "${doc.trackingLink}",
  "totalClicks": ${doc.totalClicks},
  "totalOrders": ${doc.totalOrders},
  "totalBusiness": ${String.format("%.2f", doc.totalBusiness)}
}"""
        }
        else -> doc.toString()
    }
}

// 6. Own Product Upload
@Composable
fun ProductSubmission() {
    var brandName by remember { mutableStateOf("") }
    var prodDscp by remember { mutableStateOf("") }
    var isSaving by remember { mutableStateOf(false) }

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Enter customized brand deliverables to register promotional targets into our matching pool.",
            color = LightAccent,
            fontSize = 11.sp
        )

        OutlinedTextField(
            value = brandName,
            onValueChange = { brandName = it },
            placeholder = { Text(text = "Brand Product Title", color = LightAccent, fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            maxLines = 1,
            colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = LightAccent)
        )

        OutlinedTextField(
            value = prodDscp,
            onValueChange = { prodDscp = it },
            placeholder = { Text(text = "Brief description and keywords", color = LightAccent, fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            maxLines = 3,
            colors = OutlinedTextFieldDefaults.colors(focusedTextColor = Color.White, unfocusedTextColor = LightAccent)
        )

        Button(
            onClick = {
                isSaving = true
            },
            enabled = brandName.isNotBlank() && !isSaving,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen)
        ) {
            Text(text = if (isSaving) "Uploading Assets..." else "Save Product", fontWeight = FontWeight.Bold)
        }
    }
}

// 7. Otp Verification Screen
@Composable
fun OtpVerificationScreen() {
    val pendingApprovedList = FirestoreDb.product_promotions.filter { !it.otpVerified }
    var selectedPromoId by remember { mutableStateOf(pendingApprovedList.firstOrNull()?.id ?: "") }
    var otpCode by remember { mutableStateOf("") }
    var errorMsg by remember { mutableStateOf<String?>(null) }
    var verifiedRecordId by remember { mutableStateOf<String?>(null) }

    // Synchronize selection if requests update reactively in database
    LaunchedEffect(pendingApprovedList) {
        if ((selectedPromoId.isEmpty() || !pendingApprovedList.any { it.id == selectedPromoId }) && pendingApprovedList.isNotEmpty()) {
            selectedPromoId = pendingApprovedList.first().id
        }
    }

    LazyColumn(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(14.dp),
        contentPadding = PaddingValues(vertical = 4.dp)
    ) {
        item {
            Text(
                text = "Enter the 6-digit OTP code authorized in the Vendor tab to verify your promo and unlock your unique referral links.",
                color = LightAccent,
                fontSize = 11.sp,
                lineHeight = 15.sp
            )
        }

        if (pendingApprovedList.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFF0F172A))
                        .padding(20.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = EmeraldGreen,
                            modifier = Modifier.size(32.dp)
                        )
                        Text(
                            text = "No pending OTP campaigns left to verify!",
                            color = Color.White,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Text(
                            text = "Go to 'Product Promo Requests' and submit a new campaign request first.",
                            color = LightAccent,
                            fontSize = 10.sp,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            }
        } else {
            item {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(text = "Select Campaign to Verify", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    pendingApprovedList.forEach { promo ->
                        val isSelected = selectedPromoId == promo.id
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(10.dp))
                                .background(if (isSelected) CardBorderColor.copy(alpha = 0.3f) else Color(0x1AFFFFFF))
                                .border(1.dp, if (isSelected) ElectricBlue else Color.Transparent, RoundedCornerShape(10.dp))
                                .clickable { selectedPromoId = promo.id }
                                .padding(10.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(
                                    text = "${promo.productName} (ID: ${promo.id})",
                                    color = Color.White,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Text(text = "Creator: ${promo.influencerId} | Vendor ID: ${promo.vendorId}", color = LightAccent, fontSize = 9.sp)
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                                    modifier = Modifier.padding(top = 2.dp)
                                ) {
                                    val statusColor = if (promo.status == "APPROVED") EmeraldGreen else Color(0xFFFFB300)
                                    Box(modifier = Modifier.size(6.dp).clip(CircleShape).background(statusColor))
                                    Text(text = "Status: ${promo.status}", color = statusColor, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                                }
                            }
                            RadioButton(
                                selected = isSelected,
                                onClick = { selectedPromoId = promo.id },
                                colors = RadioButtonDefaults.colors(selectedColor = ElectricBlue, unselectedColor = LightAccent)
                            )
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                    }
                }
            }

            item {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Enter 6-Digit OTP Code",
                        color = Color.White,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.fillMaxWidth(),
                        textAlign = TextAlign.Start
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        repeat(6) { idx ->
                            val textChar = if (idx < otpCode.length) otpCode[idx].toString() else ""
                            Box(
                                modifier = Modifier
                                    .size(width = 38.dp, height = 44.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(Color(0xFF0F172A))
                                    .border(
                                        1.dp,
                                        if (otpCode.length == 6) EmeraldGreen else ElectricBlue,
                                        RoundedCornerShape(8.dp)
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(text = textChar, color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Black)
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    // Embedded secure keypad for testing within the responsive preview
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        val keys = listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "Del", "0", "Verify")
                        val keypadGrid = keys.chunked(3)

                        keypadGrid.forEach { rowKeys ->
                            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                rowKeys.forEach { currentKey ->
                                    Box(
                                        modifier = Modifier
                                            .size(width = 70.dp, height = 34.dp)
                                            .clip(RoundedCornerShape(8.dp))
                                            .background(CardSlate)
                                            .border(1.dp, CardBorderColor.copy(alpha = 0.5f), RoundedCornerShape(8.dp))
                                            .clickable {
                                                if (currentKey == "Del") {
                                                    if (otpCode.isNotEmpty()) otpCode = otpCode.dropLast(1)
                                                    errorMsg = null
                                                } else if (currentKey == "Verify") {
                                                    if (otpCode.length != 6) {
                                                        errorMsg = "Error: Input must equal exactly 6 numeric digits."
                                                    } else {
                                                        val confirmed = FirestoreDb.verifyPromotionOtp(selectedPromoId, otpCode)
                                                        if (confirmed) {
                                                            errorMsg = null
                                                            verifiedRecordId = selectedPromoId
                                                            otpCode = ""
                                                        } else {
                                                            errorMsg = "Verification OTP mismatched or campaign was not approved yet. Look inside active OTP codes on the Vendor Workspace."
                                                        }
                                                    }
                                                } else {
                                                    if (otpCode.length < 6) otpCode += currentKey
                                                }
                                            },
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(text = currentKey, color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        errorMsg?.let { err ->
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color(0x33F43F5E))
                        .border(1.dp, Color(0xFFF43F5E), RoundedCornerShape(8.dp))
                        .padding(10.dp)
                ) {
                    Text(text = err, color = Color(0xFFFDA4AF), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }
        }

        if (FirestoreDb.affiliate_links.isNotEmpty()) {
            item {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = EmeraldGreen, modifier = Modifier.size(16.dp))
                        Text(text = "Unlocked Affiliate & Tracking Codes", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }

                    FirestoreDb.affiliate_links.forEach { link ->
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(CardSlate)
                                .border(1.dp, EmeraldGreen.copy(alpha = 0.4f), RoundedCornerShape(12.dp))
                                .padding(12.dp)
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                Text(text = link.productName, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)

                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(6.dp))
                                        .background(Color(0xFF0F172A))
                                        .padding(8.dp)
                                ) {
                                    Text(text = "Referral Code: ${link.referralCode}", color = ElectricBlue, fontSize = 11.sp, fontWeight = FontWeight.Bold, fontFamily = FontFamily.Monospace)
                                    Text(text = "Promo URL: ${link.trackingLink}", color = LightAccent, fontSize = 9.sp, fontFamily = FontFamily.Monospace)
                                }

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Column {
                                        Text(text = "totalClicks", color = LightAccent, fontSize = 9.sp)
                                        Text(text = "${link.totalClicks}", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                    }
                                    Column {
                                        Text(text = "totalOrders", color = LightAccent, fontSize = 9.sp)
                                        Text(text = "${link.totalOrders}", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                    }
                                    Column {
                                        Text(text = "totalBusiness", color = LightAccent, fontSize = 9.sp)
                                        Text(text = "$${String.format("%.2f", link.totalBusiness)}", color = EmeraldGreen, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                                    }
                                }

                                Row(
                                    modifier = Modifier.fillMaxWidth().padding(top = 4.dp),
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Button(
                                        onClick = {
                                            FirestoreDb.simulateAffiliateMetrics(link.id, clicks = 10, orders = 0, revenue = 0.0)
                                        },
                                        modifier = Modifier.weight(1f),
                                        colors = ButtonDefaults.buttonColors(containerColor = CardBorderColor),
                                        contentPadding = PaddingValues(vertical = 4.dp, horizontal = 4.dp),
                                        shape = RoundedCornerShape(6.dp)
                                    ) {
                                        Text(text = "+10 Clicks", fontSize = 10.sp, color = Color.White)
                                    }
                                    Button(
                                        onClick = {
                                            val revenueVal = when (link.productId) {
                                                "prod_hydrate" -> 35.00
                                                "prod_peaks" -> 19.99
                                                "prod_sonic" -> 149.00
                                                "prod_earbuds" -> 99.99
                                                else -> 50.00
                                            }
                                            FirestoreDb.simulateAffiliateMetrics(link.id, clicks = 1, orders = 1, revenue = revenueVal)
                                        },
                                        modifier = Modifier.weight(1f),
                                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                                        contentPadding = PaddingValues(vertical = 4.dp, horizontal = 4.dp),
                                        shape = RoundedCornerShape(6.dp)
                                    ) {
                                        Text(text = "Simulate Shop Conversion", fontSize = 10.sp, color = Color.Black)
                                    }
                                }
                            }
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                    }
                }
            }
        }

        item {
            Spacer(modifier = Modifier.height(8.dp))
            FirestoreCollectionViewer(
                collectionName = "affiliate_links",
                documents = FirestoreDb.affiliate_links.toList()
            )
        }
    }
}

// Vendor OTP Request & Code Generator Screener Component
@Composable
fun VendorPromotionManager() {
    val pendingList = FirestoreDb.product_promotions.filter { it.status == "PENDING" }
    val approvedList = FirestoreDb.product_promotions.filter { it.status == "APPROVED" || it.status == "VERIFIED" }

    LazyColumn(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(14.dp),
        contentPadding = PaddingValues(vertical = 4.dp)
    ) {
        item {
            Text(
                text = "Campaign Panel: View matching influencer requests, authorize affiliate channels, and generate 6-digit verification codes.",
                color = LightAccent,
                fontSize = 11.sp,
                lineHeight = 15.sp
            )
        }

        item {
            Text(
                text = "Promotion Requests Awaiting Approval (${pendingList.size})",
                color = Color.White,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold
            )
        }

        if (pendingList.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(10.dp))
                        .background(Color(0xFF0F172A))
                        .padding(14.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "No pending requested brand sponsorships.",
                        color = LightAccent,
                        fontSize = 11.sp,
                        textAlign = TextAlign.Center
                    )
                }
            }
        } else {
            items(pendingList.size) { idx ->
                val promo = pendingList[idx]
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(CardSlate)
                        .border(1.dp, CardBorderColor, RoundedCornerShape(12.dp))
                        .padding(12.dp)
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(text = promo.productName, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(Color(0xFFFFB300).copy(alpha = 0.2f))
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(text = "PENDING", color = Color(0xFFFFB300), fontSize = 9.sp, fontWeight = FontWeight.Black)
                            }
                        }

                        Text(text = "Influencer Handle: ${promo.influencerId}", color = LightAccent, fontSize = 11.sp)
                        Text(text = "Vendor ID: ${promo.vendorId} | Product ID: ${promo.productId}", color = LightAccent.copy(alpha = 0.7f), fontSize = 10.sp)

                        Button(
                            onClick = {
                                FirestoreDb.approvePromotionRequest(promo.id)
                            },
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Icon(imageVector = Icons.Default.Check, contentDescription = null, tint = Color.Black, modifier = Modifier.size(14.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(text = "Approve and Generate 6-Digit OTP", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 11.sp)
                        }
                    }
                }
                Spacer(modifier = Modifier.height(4.dp))
            }
        }

        item {
            Text(
                text = "Authorized OTP and Contracts Register (${approvedList.size})",
                color = Color.White,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold
            )
        }

        if (approvedList.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(10.dp))
                        .background(Color(0xFF0F172A))
                        .padding(14.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "Once requests are approved, active security keys report here.",
                        color = LightAccent,
                        fontSize = 11.sp,
                        textAlign = TextAlign.Center
                    )
                }
            }
        } else {
            items(approvedList.size) { idx ->
                val promo = approvedList[idx]
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0x332B2930))
                        .border(1.dp, if (promo.otpVerified) EmeraldGreen else CardBorderColor, RoundedCornerShape(12.dp))
                        .padding(12.dp)
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(text = promo.productName, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                            val (badgeText, badgeColor) = if (promo.otpVerified) "VERIFIED" to EmeraldGreen else "APPROVED" to ElectricBlue
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(badgeColor.copy(alpha = 0.2f))
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(text = badgeText, color = badgeColor, fontSize = 9.sp, fontWeight = FontWeight.Black)
                            }
                        }

                        Text(text = "Influencer Handle: ${promo.influencerId}", color = LightAccent, fontSize = 11.sp)

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(6.dp))
                                .background(Color(0xFF0F172A))
                                .padding(8.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(text = "Active Campaign OTP:", color = LightAccent, fontSize = 10.sp)
                            Text(
                                text = promo.approvalOtp,
                                color = if (promo.otpVerified) EmeraldGreen else ElectricBlue,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Black,
                                letterSpacing = 2.sp,
                                fontFamily = FontFamily.Monospace
                            )
                        }

                        if (!promo.otpVerified) {
                            Text(
                                text = "💡 Give this code to the Influencer to verify and build their affiliate links.",
                                color = LightAccent,
                                fontSize = 9.sp,
                                lineHeight = 12.sp
                            )
                        } else {
                            Text(
                                text = "✅ Verified. Under 'affiliate_links' collection, user is registered.",
                                color = EmeraldGreen,
                                fontSize = 9.sp
                            )
                        }
                    }
                }
                Spacer(modifier = Modifier.height(4.dp))
            }
        }

        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color.Black)
                    .border(1.dp, CardBorderColor, RoundedCornerShape(12.dp))
                    .padding(12.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(text = "cloud_firestore transaction log", color = Color.White, fontSize = 11.sp, fontFamily = FontFamily.Monospace, fontWeight = FontWeight.Bold)
                Divider(color = CardBorderColor.copy(alpha = 0.4f))
                Box(modifier = Modifier.height(80.dp).verticalScroll(rememberScrollState())) {
                    Column {
                        FirestoreDb.dbTransactions.forEach { tx ->
                            Text(text = tx, color = Color(0xFFC4FF62), fontSize = 9.sp, fontFamily = FontFamily.Monospace, lineHeight = 12.sp)
                        }
                    }
                }
            }
        }
    }
}

// 8. Analytical Reels Tracker
@Composable
fun AnalyticalReelsTracker() {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Track active statistics for generated reels. Data fetched from Cloud Firestore analytics nodes.",
            color = LightAccent,
            fontSize = 11.sp
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(text = "Weekly Engagement Distribution", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(110.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(Color(0xFF0F172A))
                .padding(14.dp),
            contentAlignment = Alignment.Center
        ) {
            Canvas(modifier = Modifier.fillMaxSize()) {
                val linePoints = listOf(
                    Offset(0f, size.height * 0.9f),
                    Offset(size.width * 0.2f, size.height * 0.6f),
                    Offset(size.width * 0.4f, size.height * 0.8f),
                    Offset(size.width * 0.6f, size.height * 0.3f),
                    Offset(size.width * 0.8f, size.height * 0.4f),
                    Offset(size.width, size.height * 0.15f)
                )

                for (i in 0 until linePoints.size - 1) {
                    drawLine(
                        color = ElectricBlue,
                        start = linePoints[i],
                        end = linePoints[i + 1],
                        strokeWidth = 5f
                    )
                }
            }
        }
    }
}

// 9. Configuration Avatar Clone
@Composable
fun ConfigurationAvatarClone() {
    var smileCalibration by remember { mutableStateOf(0.7f) }
    var eyeTrackingCalibration by remember { mutableStateOf(0.4f) }

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Configure coordinates mesh for facial posture models and dynamic synthetic speaking.",
            color = LightAccent,
            fontSize = 11.sp
        )

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(100.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(Color(0xFF0F172A)),
            contentAlignment = Alignment.Center
        ) {
            Canvas(modifier = Modifier.size(80.dp)) {
                drawCircle(color = LightAccent.copy(alpha = 0.2f), radius = size.minDimension / 2)
                drawCircle(color = EmeraldGreen, radius = 6f, center = Offset(size.width * 0.35f, size.height * 0.45f))
                drawCircle(color = EmeraldGreen, radius = 6f, center = Offset(size.width * 0.65f, size.height * 0.45f))
                drawArc(
                    color = EmeraldGreen,
                    startAngle = 10f,
                    sweepAngle = 160f * smileCalibration,
                    useCenter = false,
                    style = Stroke(width = 4f),
                    size = Size(width = size.width * 0.5f, height = size.height * 0.3f),
                    topLeft = Offset(size.width * 0.25f, size.height * 0.5f)
                )
            }
        }

        Column {
            Text(text = "Mouth Alignment Strength: ${(smileCalibration * 100).toInt()}%", color = LightAccent, fontSize = 10.sp)
            Slider(
                value = smileCalibration,
                onValueChange = { smileCalibration = it },
                colors = SliderDefaults.colors(thumbColor = EmeraldGreen, activeTrackColor = EmeraldGreen)
            )
        }
    }
}

// 10. Business Invoicing Tracking
@Composable
fun BusinessInvoicingTracking() {
    val transactions = listOf(
        Pair("Product Ad Match A", "$450.00"),
        Pair("Super Hydrate Brief Match", "$820.00"),
        Pair("Peak Nutrition Reels Allocation", "$300.00")
    )

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Manage brand invoices and active promotional contracts securely on-platform.",
            color = LightAccent,
            fontSize = 11.sp
        )

        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            transactions.forEach { trans ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(10.dp))
                        .background(Color(0xFF0F172A))
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(text = trans.first, color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        Text(text = "State: Cleared/Completed", color = EmeraldGreen, fontSize = 9.sp)
                    }

                    Text(text = trans.second, color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Black)
                }
            }
        }
    }
}

// 11. Superuser Controls
@Composable
fun SuperuserControls() {
    var globalMatchingValue by remember { mutableStateOf(true) }

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Administrative regulation filters. Restrict or promote specific brands over global matcher structures.",
            color = LightAccent,
            fontSize = 11.sp
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(Color(0xFF0F172A))
                .padding(14.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(text = "Automated Influencer Dispatch", color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                Text(text = "Approve matches autonomously via prompt checks", color = LightAccent, fontSize = 10.sp)
            }

            Switch(
                checked = globalMatchingValue,
                onCheckedChange = { globalMatchingValue = it },
                colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.4f))
            )
        }
    }
}
