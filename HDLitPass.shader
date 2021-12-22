Pass
{
    // based on HDLitPass.template
    Name "$splice(PassName)"
    Tags { "LightMode" = "$splice(LightMode)" }

    //-------------------------------------------------------------------------------------
    // Render Modes (Blend, Cull, ZTest, Stencil, etc)
    //-------------------------------------------------------------------------------------
    $splice(Blending)
    $splice(Culling)
    $splice(ZTest)
    $splice(ZWrite)
    $splice(ZClip)
    $splice(Stencil)
    $splice(ColorMask)
    //-------------------------------------------------------------------------------------
    // End Render Modes
    //-------------------------------------------------------------------------------------

    HLSLPROGRAM

    #pragma target 4.5

    //#pragma enable_d3d11_debug_symbols

    $splice(InstancingOptions)

    $LodCrossFade: #pragma multi_compile _ LOD_FADE_CROSSFADE

    #pragma shader_feature _SURFACE_TYPE_TRANSPARENT
    #pragma shader_feature_local _DOUBLESIDED_ON
    #pragma shader_feature_local _ _BLENDMODE_ALPHA _BLENDMODE_ADD _BLENDMODE_PRE_MULTIPLY
    #pragma shader_feature_local _ENABLE_FOG_ON_TRANSPARENT
    #pragma shader_feature_local _ALPHATEST_ON

    //-------------------------------------------------------------------------------------
    // Graph Defines
    //-------------------------------------------------------------------------------------
    $splice(Defines)
    //-------------------------------------------------------------------------------------
    // End Defines
    //-------------------------------------------------------------------------------------

    //-------------------------------------------------------------------------------------
    // Variant Definitions (active field translations to HDRP defines)
    //-------------------------------------------------------------------------------------

    $Material.SubsurfaceScattering:      #define _MATERIAL_FEATURE_SUBSURFACE_SCATTERING 1
    $Material.Transmission:              #define _MATERIAL_FEATURE_TRANSMISSION 1
    $Material.Anisotropy:                #define _MATERIAL_FEATURE_ANISOTROPY 1
    $Material.Iridescence:               #define _MATERIAL_FEATURE_IRIDESCENCE 1
    $Material.SpecularColor:             #define _MATERIAL_FEATURE_SPECULAR_COLOR 1
    $AmbientOcclusion:                   #define _AMBIENT_OCCLUSION 1
    $SpecularOcclusionFromAO:            #define _SPECULAR_OCCLUSION_FROM_AO 1
    $SpecularOcclusionFromAOBentNormal:  #define _SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL 1
    $SpecularOcclusionCustom:            #define _SPECULAR_OCCLUSION_CUSTOM 1
    $Specular.EnergyConserving:          #define _ENERGY_CONSERVING_SPECULAR 1
#if !defined(SHADER_STAGE_RAY_TRACING)
    $Specular.AA:                        #define _ENABLE_GEOMETRIC_SPECULAR_AA 1
#endif
    $Refraction:                         #define _HAS_REFRACTION 1
    $RefractionBox:                      #define _REFRACTION_PLANE 1
    $RefractionSphere:                   #define _REFRACTION_SPHERE 1
    $RefractionThin:                     #define _REFRACTION_THIN 1
    $DisableDecals:                      #define _DISABLE_DECALS 1
    $DisableSSR:                         #define _DISABLE_SSR 1
    $AddPrecomputedVelocity:           #define _ADD_PRECOMPUTED_VELOCITY
    $TransparentWritesMotionVec:         #define _WRITE_TRANSPARENT_MOTION_VECTOR 1
    $DepthOffset:                        #define _DEPTHOFFSET_ON 1
    $BlendMode.PreserveSpecular:        #define _BLENDMODE_PRESERVE_SPECULAR_LIGHTING 1
    $NormalDropOffTS:		        #define _NORMAL_DROPOFF_TS 1
    $NormalDropOffOS:		        #define _NORMAL_DROPOFF_OS 1
    $NormalDropOffWS:		        #define _NORMAL_DROPOFF_WS 1

    //-------------------------------------------------------------------------------------
    // End Variant Definitions
    //-------------------------------------------------------------------------------------

    //-------------------------------------------------------------------------------------
    // Shader stages
    //-------------------------------------------------------------------------------------
    $splice(ShaderStages)

    // If we use subsurface scattering, enable output split lighting (for forward pass)
    #if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
    #define OUTPUT_SPLIT_LIGHTING
    #endif

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

#if !defined(SHADER_STAGE_RAY_TRACING)
    // This cannot be included, the instructions that are required are not defined if we are not in a rasterization context
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
#endif

    // define FragInputs structure
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

    //-------------------------------------------------------------------------------------
    // Active Field Defines
    //-------------------------------------------------------------------------------------

    // this translates the new dependency tracker into the old preprocessor definitions for the existing HDRP shader code
    $AttributesMesh.normalOS:               #define ATTRIBUTES_NEED_NORMAL
    $AttributesMesh.tangentOS:              #define ATTRIBUTES_NEED_TANGENT
    $AttributesMesh.uv0:                    #define ATTRIBUTES_NEED_TEXCOORD0
    $AttributesMesh.uv1:                    #define ATTRIBUTES_NEED_TEXCOORD1
    $AttributesMesh.uv2:                    #define ATTRIBUTES_NEED_TEXCOORD2
    $AttributesMesh.uv3:                    #define ATTRIBUTES_NEED_TEXCOORD3
    $AttributesMesh.color:                  #define ATTRIBUTES_NEED_COLOR
    $VaryingsMeshToPS.positionRWS:          #define VARYINGS_NEED_POSITION_WS
    $VaryingsMeshToPS.normalWS:             #define VARYINGS_NEED_TANGENT_TO_WORLD
    $VaryingsMeshToPS.texCoord0:            #define VARYINGS_NEED_TEXCOORD0
    $VaryingsMeshToPS.texCoord1:            #define VARYINGS_NEED_TEXCOORD1
    $VaryingsMeshToPS.texCoord2:            #define VARYINGS_NEED_TEXCOORD2
    $VaryingsMeshToPS.texCoord3:            #define VARYINGS_NEED_TEXCOORD3
    $VaryingsMeshToPS.color:                #define VARYINGS_NEED_COLOR
    $VaryingsMeshToPS.cullFace:             #define VARYINGS_NEED_CULLFACE
    $features.modifyMesh:                   #define HAVE_MESH_MODIFICATION

// We need isFontFace when using double sided
#if defined(_DOUBLESIDED_ON) && !defined(VARYINGS_NEED_CULLFACE)
    #define VARYINGS_NEED_CULLFACE
#endif

    //-------------------------------------------------------------------------------------
    // End Defines
    //-------------------------------------------------------------------------------------
	$splice(DotsInstancedVars)
#if !defined(SHADER_STAGE_RAY_TRACING)
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #ifdef DEBUG_DISPLAY
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
    #endif

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"

    #if (SHADERPASS == SHADERPASS_FORWARD)
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"

        #define HAS_LIGHTLOOP

        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
    #else
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
    #endif

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
#else

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/RaytracingMacros.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/ShaderVariablesRaytracing.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/ShaderVariablesRaytracingLightLoop.hlsl"
    #if (SHADERPASS == SHADERPASS_RAYTRACING_GBUFFER)
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/Deferred/RaytracingIntersectonGBuffer.hlsl"
    #elif (SHADERPASS == SHADERPASS_RAYTRACING_SUB_SURFACE)
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/SubSurface/RayTracingIntersectionSubSurface.hlsl"
    #else
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/RaytracingIntersection.hlsl"
    #endif
    #if (SHADERPASS == SHADERPASS_RAYTRACING_INDIRECT) || (SHADERPASS == SHADERPASS_RAYTRACING_FORWARD) || (SHADERPASS == SHADERPASS_PATH_TRACING)
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        #define HAS_LIGHTLOOP
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
    #endif
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
    #if (SHADERPASS == SHADERPASS_RAYTRACING_GBUFFER)
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/StandardLit/StandardLit.hlsl"
    #endif
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitRaytracing.hlsl"
    #if (SHADERPASS == SHADERPASS_RAYTRACING_INDIRECT) || (SHADERPASS == SHADERPASS_RAYTRACING_FORWARD)
        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/RaytracingLightLoop.hlsl"
    #endif
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/Raytracing/Shaders/RaytracingCommon.hlsl"
#endif

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

    // Used by SceneSelectionPass
    int _ObjectId;
    int _PassValue;

    //-------------------------------------------------------------------------------------
    // Interpolator Packing And Struct Declarations
    //-------------------------------------------------------------------------------------
#if !defined(SHADER_STAGE_RAY_TRACING)
    // This types only make sense in the rasterization pipeline
    $buildType(AttributesMesh)
    $buildType(VaryingsMeshToPS)
    $buildType(VaryingsMeshToDS)
#endif

    //-------------------------------------------------------------------------------------
    // End Interpolator Packing And Struct Declarations
    //-------------------------------------------------------------------------------------

    //-------------------------------------------------------------------------------------
    // Graph generated code
    //-------------------------------------------------------------------------------------
    $splice(Graph)
    //-------------------------------------------------------------------------------------
    // End graph generated code
    //-------------------------------------------------------------------------------------

#if !defined(SHADER_STAGE_RAY_TRACING)
    // Vertex animation is not supported in the ray tracing context
    $features.modifyMesh:   $include("VertexAnimation.template.hlsl")
#endif

    $include("SharedCode.template.hlsl")

    void BuildSurfaceData(FragInputs fragInputs, inout SurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData, out float3 bentNormalWS)
    {
        // setup defaults -- these are used if the graph doesn't output a value
        ZERO_INITIALIZE(SurfaceData, surfaceData);

        // specularOcclusion need to be init ahead of decal to quiet the compiler that modify the SurfaceData struct
        // however specularOcclusion can come from the graph, so need to be init here so it can be override.
        surfaceData.specularOcclusion = 1.0;

        // copy across graph values, if defined
        $SurfaceDescription.Albedo:                     surfaceData.baseColor =                 surfaceDescription.Albedo;
        $SurfaceDescription.Smoothness:                 surfaceData.perceptualSmoothness =      surfaceDescription.Smoothness;
        $SurfaceDescription.Occlusion:                  surfaceData.ambientOcclusion =          surfaceDescription.Occlusion;
        $SurfaceDescription.SpecularOcclusion:          surfaceData.specularOcclusion =         surfaceDescription.SpecularOcclusion;
        $SurfaceDescription.Metallic:                   surfaceData.metallic =                  surfaceDescription.Metallic;
        $SurfaceDescription.SubsurfaceMask:             surfaceData.subsurfaceMask =            surfaceDescription.SubsurfaceMask;
        $SurfaceDescription.Thickness:                  surfaceData.thickness =                 surfaceDescription.Thickness;
        $SurfaceDescription.DiffusionProfileHash:       surfaceData.diffusionProfileHash =      asuint(surfaceDescription.DiffusionProfileHash);
        $SurfaceDescription.Specular:                   surfaceData.specularColor =             surfaceDescription.Specular;
        $SurfaceDescription.CoatMask:                   surfaceData.coatMask =                  surfaceDescription.CoatMask;
        $SurfaceDescription.Anisotropy:                 surfaceData.anisotropy =                surfaceDescription.Anisotropy;
        $SurfaceDescription.IridescenceMask:            surfaceData.iridescenceMask =           surfaceDescription.IridescenceMask;
        $SurfaceDescription.IridescenceThickness:       surfaceData.iridescenceThickness =      surfaceDescription.IridescenceThickness;

#ifdef _HAS_REFRACTION
        if (_EnableSSRefraction)
        {
            $SurfaceDescription.RefractionIndex:            surfaceData.ior =                       surfaceDescription.RefractionIndex;
            $SurfaceDescription.RefractionColor:            surfaceData.transmittanceColor =        surfaceDescription.RefractionColor;
            $SurfaceDescription.RefractionDistance:         surfaceData.atDistance =                surfaceDescription.RefractionDistance;

            surfaceData.transmittanceMask = (1.0 - surfaceDescription.Alpha);
            surfaceDescription.Alpha = 1.0;
        }
        else
        {
            surfaceData.ior = 1.0;
            surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
            surfaceData.atDistance = 1.0;
            surfaceData.transmittanceMask = 0.0;
            surfaceDescription.Alpha = 1.0;
        }
#else
        surfaceData.ior = 1.0;
        surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
        surfaceData.atDistance = 1.0;
        surfaceData.transmittanceMask = 0.0;
#endif

        // These static material feature allow compile time optimization
        surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
#endif
#ifdef _MATERIAL_FEATURE_TRANSMISSION
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
#endif
#ifdef _MATERIAL_FEATURE_ANISOTROPY
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
#endif
        $CoatMask: surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;

#ifdef _MATERIAL_FEATURE_IRIDESCENCE
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
#endif
#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
        surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
#endif

#if defined (_MATERIAL_FEATURE_SPECULAR_COLOR) && defined (_ENERGY_CONSERVING_SPECULAR)
        // Require to have setup baseColor
        // Reproduce the energy conservation done in legacy Unity. Not ideal but better for compatibility and users can unchek it
        surfaceData.baseColor *= (1.0 - Max3(surfaceData.specularColor.r, surfaceData.specularColor.g, surfaceData.specularColor.b));
#endif

#ifdef _DOUBLESIDED_ON
    float3 doubleSidedConstants = _DoubleSidedConstants.xyz;
#else
    float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
#endif

        // normal delivered to master node
        float3 normalSrc = float3(0.0f, 0.0f, 1.0f);
        $SurfaceDescription.Normal: normalSrc = surfaceDescription.Normal;

        // compute world space normal
#if _NORMAL_DROPOFF_TS
        GetNormalWS(fragInputs, normalSrc, surfaceData.normalWS, doubleSidedConstants);
#elif _NORMAL_DROPOFF_OS
		surfaceData.normalWS = TransformObjectToWorldNormal(normalSrc);
#elif _NORMAL_DROPOFF_WS
		surfaceData.normalWS = normalSrc;
#endif

        surfaceData.geomNormalWS = fragInputs.tangentToWorld[2];

        surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    // The tangent is not normalize in tangentToWorld for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
        $Tangent: surfaceData.tangentWS = TransformTangentToWorld(surfaceDescription.Tangent, fragInputs.tangentToWorld);

#if HAVE_DECALS
        if (_EnableDecals)
        {
            // Both uses and modifies 'surfaceData.normalWS'.
            DecalSurfaceData decalSurfaceData = GetDecalSurfaceData(posInput, surfaceDescription.Alpha);
            ApplyDecalToSurfaceData(decalSurfaceData, surfaceData);
        }
#endif

        bentNormalWS = surfaceData.normalWS;
        $BentNormal: GetNormalWS(fragInputs, surfaceDescription.BentNormal, bentNormalWS, doubleSidedConstants);

        surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);

#if defined(DEBUG_DISPLAY) && !defined(SHADER_STAGE_RAY_TRACING)
        if (_DebugMipMapMode != DEBUGMIPMAPMODE_NONE)
        {
            // TODO: need to update mip info
            surfaceData.metallic = 0;
        }

        // We need to call ApplyDebugToSurfaceData after filling the surfarcedata and before filling builtinData
        // as it can modify attribute use for static lighting
        ApplyDebugToSurfaceData(fragInputs.tangentToWorld, surfaceData);
#endif

        // By default we use the ambient occlusion with Tri-ace trick (apply outside) for specular occlusion.
        // If user provide bent normal then we process a better term
#if defined(_SPECULAR_OCCLUSION_CUSTOM)
        // Just use the value passed through via the slot (not active otherwise)
#elif defined(_SPECULAR_OCCLUSION_FROM_AO_BENT_NORMAL)
        // If we have bent normal and ambient occlusion, process a specular occlusion
        surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData.normalWS, surfaceData.ambientOcclusion, PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness));
#elif defined(_AMBIENT_OCCLUSION) && defined(_SPECULAR_OCCLUSION_FROM_AO)
        surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(ClampNdotV(dot(surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
#endif

#ifdef _ENABLE_GEOMETRIC_SPECULAR_AA
        surfaceData.perceptualSmoothness = GeometricNormalFiltering(surfaceData.perceptualSmoothness, fragInputs.tangentToWorld[2], surfaceDescription.SpecularAAScreenSpaceVariance, surfaceDescription.SpecularAAThreshold);
#endif
    }

    void GetSurfaceAndBuiltinData(FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData RAY_TRACING_OPTIONAL_PARAMETERS)
    {
#ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
        LODDitheringTransition(ComputeFadeMaskSeed(V, posInput.positionSS), unity_LODFade.x);
#endif

#ifdef _DOUBLESIDED_ON
    float3 doubleSidedConstants = _DoubleSidedConstants.xyz;
#else
    float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
#endif

        ApplyDoubleSidedFlipOrMirror(fragInputs, doubleSidedConstants);

        SurfaceDescriptionInputs surfaceDescriptionInputs = FragInputsToSurfaceDescriptionInputs(fragInputs, V);
        SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);

        // Perform alpha test very early to save performance (a killed pixel will not sample textures)
        // TODO: split graph evaluation to grab just alpha dependencies first? tricky..
#ifdef _ALPHATEST_ON
        $AlphaTest:         GENERIC_ALPHA_TEST(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);
        $AlphaTestPrepass:  GENERIC_ALPHA_TEST(surfaceDescription.Alpha, surfaceDescription.AlphaClipThresholdDepthPrepass);
        $AlphaTestPostpass: GENERIC_ALPHA_TEST(surfaceDescription.Alpha, surfaceDescription.AlphaClipThresholdDepthPostpass);
        $AlphaTestShadow:   GENERIC_ALPHA_TEST(surfaceDescription.Alpha, surfaceDescription.AlphaClipThresholdShadow);
#endif

        $DepthOffset: ApplyDepthOffsetPositionInput(V, surfaceDescription.DepthOffset, GetViewForwardDir(), GetWorldToHClipMatrix(), posInput);

        float3 bentNormalWS;
        BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData, bentNormalWS);

        // Builtin Data
        // For back lighting we use the oposite vertex normal
        InitBuiltinData(posInput, surfaceDescription.Alpha, bentNormalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);

        // override sampleBakedGI:
        $LightingGI: builtinData.bakeDiffuseLighting = surfaceDescription.BakedGI;
        $BackLightingGI: builtinData.backBakeDiffuseLighting = surfaceDescription.BakedBackGI;

        $SurfaceDescription.Emission: builtinData.emissiveColor = surfaceDescription.Emission;

        $DepthOffset: builtinData.depthOffset = surfaceDescription.DepthOffset;

#if (SHADERPASS == SHADERPASS_DISTORTION)
        builtinData.distortion = surfaceDescription.Distortion;
        builtinData.distortionBlur = surfaceDescription.DistortionBlur;
#else
        builtinData.distortion = float2(0.0, 0.0);
        builtinData.distortionBlur = 0.0;
#endif

        PostInitBuiltinData(V, posInput, surfaceData, builtinData);

        RAY_TRACING_OPTIONAL_ALPHA_TEST_PASS
    }

    //-------------------------------------------------------------------------------------
    // Pass Includes
    //-------------------------------------------------------------------------------------
$splice(Includes)
    //-------------------------------------------------------------------------------------
    // End Pass Includes
    //-------------------------------------------------------------------------------------

    ENDHLSL
}
