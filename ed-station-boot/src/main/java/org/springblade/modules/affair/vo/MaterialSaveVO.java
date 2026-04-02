/**
 * BladeX Commercial License Agreement
 * Copyright (c) 2018-2099, https://bladex.cn. All rights reserved.
 * <p>
 * Use of this software is governed by the Commercial License Agreement
 * obtained after purchasing a license from BladeX.
 * <p>
 * 1. This software is for development use only under a valid license
 * from BladeX.
 * <p>
 * 2. Redistribution of this software's source code to any third party
 * without a commercial license is strictly prohibited.
 * <p>
 * 3. Licensees may copyright their own code but cannot use segments
 * from this software for such purposes. Copyright of this software
 * remains with BladeX.
 * <p>
 * Using this software signifies agreement to this License, and the software
 * must not be used for illegal purposes.
 * <p>
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY. The author is
 * not liable for any claims arising from secondary or illegal development.
 * <p>
 * Author: coderleehd
 */
package org.springblade.modules.affair.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 材料保存视图类
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@Data
@Schema(description = "材料保存视图类")
public class MaterialSaveVO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键 ID（修改时必填）
     */
    @Schema(description = "主键 ID")
    private Long id;

    /**
     * 材料名称
     */
    @Schema(description = "材料名称", required = true)
    @NotBlank(message = "材料名称不能为空")
    private String materialName;

    /**
     * 材料类型
     */
    @Schema(description = "材料类型", required = true)
    @NotBlank(message = "材料类型不能为空")
    private String materialType;

    /**
     * 份数要求
     */
    @Schema(description = "份数要求", required = true)
    @NotNull(message = "份数要求不能为空")
    private Integer materialCopies;

    /**
     * 材料说明
     */
    @Schema(description = "材料说明")
    private String materialRemark;

    /**
     * 附件 ID
     */
    @Schema(description = "附件 ID", required = true)
    @NotNull(message = "附件 ID 不能为空")
    private Long attachId;

}
