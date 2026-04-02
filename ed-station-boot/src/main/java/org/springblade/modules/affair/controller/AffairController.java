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
package org.springblade.modules.affair.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.github.xiaoymin.knife4j.annotations.ApiOperationSupport;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springblade.common.constant.CommonConstant;
import org.springblade.core.boot.ctrl.BladeController;
import org.springblade.core.mp.support.Condition;
import org.springblade.core.mp.support.Query;
import org.springblade.core.secure.annotation.PreAuth;
import org.springblade.core.tenant.annotation.TenantDS;
import org.springblade.core.tool.api.R;
import org.springblade.core.tool.utils.Func;
import org.springblade.modules.affair.model.entity.Affair;
import org.springblade.modules.affair.service.IAffairService;
import org.springblade.modules.affair.vo.AffairDetailVO;
import org.springblade.modules.affair.vo.AffairSaveVO;
import org.springblade.modules.affair.vo.AffairUpdateVO;
import org.springblade.modules.affair.vo.AffairVO;
import org.springblade.modules.affair.wrapper.AffairWrapper;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 政务服务事项管理 Controller
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@TenantDS
@RestController
@AllArgsConstructor
@PreAuth(menu = "affair")
@RequestMapping(CommonConstant.APPLICATION_AFFAIR_NAME + "/affair")
@Tag(name = "事项管理", description = "政务服务事项管理接口")
public class AffairController extends BladeController {

    private final IAffairService affairService;

    /**
     * 分页查询
     */
    @GetMapping("/list")
    @ApiOperationSupport(order = 1)
    @Operation(summary = "分页查询", description = "传入分页参数和查询条件")
    public R<IPage<AffairVO>> list(@Parameter(hidden = true) @RequestParam Map<String, Object> params,
                                   Query query) {
        IPage<Affair> affairPage = affairService.page(Condition.getPage(query), Condition.getQueryWrapper(params, Affair.class));
        return R.data(AffairWrapper.build().pageVO(affairPage));
    }

    /**
     * 详情查询
     */
    @GetMapping("/detail")
    @ApiOperationSupport(order = 2)
    @Operation(summary = "详情查询", description = "传入事项 ID")
    public R<AffairDetailVO> detail(@RequestParam Long id) {
        AffairDetailVO detail = affairService.getDetail(id);
        return R.data(detail);
    }

    /**
     * 事项新增
     */
    @PostMapping("/save")
    @ApiOperationSupport(order = 3)
    @Operation(summary = "新增事项", description = "传入事项信息（含材料列表）")
    public R<Boolean> save(@Valid @RequestBody AffairSaveVO vo) {
        boolean temp = affairService.saveAffair(vo);
        return R.status(temp);
    }

    /**
     * 事项修改
     */
    @PostMapping("/update")
    @ApiOperationSupport(order = 4)
    @Operation(summary = "修改事项", description = "传入事项信息（含材料列表）")
    public R<Boolean> update(@Valid @RequestBody AffairUpdateVO vo) {
        boolean temp = affairService.updateAffair(vo);
        return R.status(temp);
    }

    /**
     * 事项删除
     */
    @PostMapping("/remove")
    @ApiOperationSupport(order = 5)
    @Operation(summary = "删除事项", description = "传入事项 ID（支持批量，逗号分隔）")
    public R<Boolean> remove(@Parameter(description = "事项 ID 集合 (逗号分隔)", required = true)
                             @RequestParam String ids) {
        boolean temp = affairService.removeAffair(ids);
        return R.status(temp);
    }

    /**
     * 事项发布
     */
    @PostMapping("/publish")
    @PreAuth(menu = "affair_publish")
    @ApiOperationSupport(order = 6)
    @Operation(summary = "发布事项", description = "传入事项 ID")
    public R<Boolean> publish(@RequestParam Long id) {
        boolean temp = affairService.publish(id);
        return R.status(temp);
    }

    /**
     * 事项下架
     */
    @PostMapping("/unpublish")
    @PreAuth(menu = "affair_unpublish")
    @ApiOperationSupport(order = 7)
    @Operation(summary = "下架事项", description = "传入事项 ID")
    public R<Boolean> unpublish(@RequestParam Long id) {
        boolean temp = affairService.unpublish(id);
        return R.status(temp);
    }

}
