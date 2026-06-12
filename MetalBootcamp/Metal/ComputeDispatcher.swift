import Metal
import MetalKit

// MARK: - Compute dispatcher

/// Универсальный хелпер для диспетчеризации 2D compute-прохода.
/// Автоматически выбирает оптимальный путь:
/// - dispatchThreads (nonuniform) на Apple4 / Mac2 и новее
/// - dispatchThreadgroups с округлением вверх на старых GPU
///
/// В обоих случаях все пиксели текстуры обрабатываются корректно.
struct ComputeDispatcher {

    // MARK: Cached support flag

    /// Кэшируем результат проверки один раз — вызов supportsFamily небесплатный.
    private let supportsNonuniform: Bool

    init(device: MTLDevice) {
        supportsNonuniform =
            device.supportsFamily(.apple4) ||
            device.supportsFamily(.mac2)
        // Примечание: .metal3 — это уровень API, не GPU-семейство.
        // Nonuniform threadgroups определяются именно GPU-семейством.
    }

    // MARK: Threadgroup size

    /// Оптимальный размер threadgroup для данного pipeline.
    /// w = threadExecutionWidth (обычно 32), h заполняет остаток до лимита.
    func threadsPerThreadgroup(
        for pipeline: MTLComputePipelineState
    ) -> MTLSize {
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        return MTLSize(width: w, height: h, depth: 1)
    }

    // MARK: Dispatch

    /// Диспетчеризация по размеру текстуры.
    func dispatch(
        encoder: MTLComputeCommandEncoder,
        pipeline: MTLComputePipelineState,
        textureWidth: Int,
        textureHeight: Int
    ) {
        let tpg = threadsPerThreadgroup(for: pipeline)

        if supportsNonuniform {
            // dispatchThreads — GPU сам обрезает неполные threadgroups на границах.
            // Никакой проверки в шейдере не нужно.
            encoder.dispatchThreads(
                MTLSize(width: textureWidth, height: textureHeight, depth: 1),
                threadsPerThreadgroup: tpg
            )
        } else {
            // Округляем вверх, чтобы покрыть все пиксели.
            // В шейдере ОБЯЗАТЕЛЬНА проверка:
            //   if (gid.x >= textureWidth || gid.y >= textureHeight) { return; }
            let gridW = (textureWidth  + tpg.width  - 1) / tpg.width
            let gridH = (textureHeight + tpg.height - 1) / tpg.height
            encoder.dispatchThreadgroups(
                MTLSize(width: gridW, height: gridH, depth: 1),
                threadsPerThreadgroup: tpg
            )
        }
    }

    /// Удобная перегрузка — принимает MTLTexture напрямую.
    func dispatch(
        encoder: MTLComputeCommandEncoder,
        pipeline: MTLComputePipelineState,
        texture: MTLTexture
    ) {
        dispatch(
            encoder: encoder,
            pipeline: pipeline,
            textureWidth: texture.width,
            textureHeight: texture.height
        )
    }
}
