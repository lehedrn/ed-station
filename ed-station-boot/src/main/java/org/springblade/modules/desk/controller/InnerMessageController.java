package org.springblade.modules.desk.controller;

import java.util.Map;

import org.springblade.core.launch.constant.AppConstant;
import org.springblade.core.mp.support.Condition;
import org.springblade.core.mp.support.Query;
import org.springblade.core.secure.annotation.PreAuth;
import org.springblade.core.tenant.annotation.TenantDS;
import org.springblade.core.tool.api.R;
import org.springblade.core.tool.utils.Func;
import org.springblade.core.xss.annotation.XssIgnore;
import org.springblade.modules.desk.pojo.entity.InnerMessage;
import org.springblade.modules.desk.pojo.vo.InnerMessageVO;
import org.springblade.modules.desk.service.IInnerMessageService;
import org.springblade.modules.desk.wrapper.InnerMessageWrapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.github.xiaoymin.knife4j.annotations.ApiOperationSupport;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.Parameters;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;

@TenantDS
@RestController
@AllArgsConstructor
@PreAuth(menu = "innermessage")
@RequestMapping(AppConstant.APPLICATION_DESK_NAME + "/innermessage")
@Tag(name = "内部消息", description = "内部消息接口")
public class InnerMessageController {
    private final IInnerMessageService innerMessageService;
    /**
	 * 详情
	 */
	@GetMapping("/detail")
	@ApiOperationSupport(order = 1)
	@Operation(summary = "详情", description = "传入innerMessage")
	public R<InnerMessageVO> detail(InnerMessage innerMessage) {
		InnerMessage detail = innerMessageService.getOne(Condition.getQueryWrapper(innerMessage));
		return R.data(InnerMessageWrapper.build().entityVO(detail));
	}
    /**
	 * 分页
	 */
	@GetMapping("/list")
	@Parameters({
		@Parameter(name = "category", description = "公告类型", in = ParameterIn.QUERY, schema = @Schema(type = "integer")),
		@Parameter(name = "title", description = "公告标题", in = ParameterIn.QUERY, schema = @Schema(type = "string"))
	})
	@ApiOperationSupport(order = 2)
	@Operation(summary = "分页", description = "传入notice")
	public R<IPage<InnerMessageVO>> list(@Parameter(hidden = true) @RequestParam Map<String, Object> innerMessage, Query query) {
		IPage<InnerMessage> pages = innerMessageService.page(Condition.getPage(query), Condition.getQueryWrapper(innerMessage, InnerMessage.class));
		return R.data(InnerMessageWrapper.build().pageVO(pages));
	}
    /**
	 * 新增
	 */
	@PostMapping("/save")
	@ApiOperationSupport(order = 4)
	@Operation(summary = "新增", description = "传入innerMessage")
	public R save(@RequestBody InnerMessage innerMessage) {
		return R.status(innerMessageService.save(innerMessage));
	}

	/**
	 * 修改
	 */
	@PostMapping("/update")
	@ApiOperationSupport(order = 5)
	@Operation(summary = "修改", description = "传入innerMessage")
	public R update(@RequestBody InnerMessage innerMessage) {
		return R.status(innerMessageService.updateById(innerMessage));
	}

	/**
	 * 新增或修改
	 */
	@XssIgnore
	@PostMapping("/submit")
	@ApiOperationSupport(order = 6)
	@Operation(summary = "新增或修改", description = "传入innerMessage")
	public R submit(@RequestBody InnerMessage innerMessage) {
		return R.status(innerMessageService.saveOrUpdate(innerMessage));
	}

	/**
	 * 删除
	 */
	@PostMapping("/remove")
	@ApiOperationSupport(order = 7)
	@Operation(summary = "逻辑删除", description = "传入innerMessage")
	public R remove(@Parameter(description = "主键集合") @RequestParam String ids) {
		boolean temp = innerMessageService.deleteLogic(Func.toLongList(ids));
		return R.status(temp);
	}

}
